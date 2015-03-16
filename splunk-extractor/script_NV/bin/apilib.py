#!/usr/bin/env python
#########################################
#                                       #
#   Lib for the API extractor script    #
#                                       #
################### by Eric Sanchez #####

# Libs Splunk
import splunklib.client as client
from time import sleep
import sys
import splunklib.results as results

# Libs argparse
import argparse

# Libs MySql
#from sqlalchemy import *

from datetime import date, timedelta
import time
from pymongo import MongoClient
import datetime
import logging
from ordereddict import OrderedDict

#####################
#   Script Defs     #
#####################

def getArgs():
    parser = argparse.ArgumentParser(description='Collect data from Splunk and Mongo and store the info in the KPIs database.')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-H', "--hourly", action ='store_true', help='Execute the searches hourly')
    group.add_argument('-D', "--daily", action ='store_true', help='Execute the searches daily')
    group.add_argument('-R', "--retryhourly", action ='store', nargs='+',  help='Retry a execution hourly')
    group.add_argument('-Z', "--retrydaily", action ='store', help='Retry a execution daily')
    #parser.add_argument('date_start', help="Starting date")
    #parser.add_argument('date_end', help="Ending date")
    args = parser.parse_args()
    return args

def check_config(config,frequency):
    if (frequency.hourly or frequency.retryhourly):
        searches=config.get('SEARCH','IDhourly').split(',')
    elif frequency.daily:
        searches=config.get('SEARCH','IDdaily').split(',')
    else:
        print "Extractor error: No mode defined (-D or -H)."
        exit(1)

    sections=config.sections()

    # Check if each search has his section defined or exist in Splunk server
    for elem in searches:
        # Check if the list is correct
        if elem in " ":
            logCreator('ERROR',"Config File Error: Error reading list of searches (check comas and blank spaces)")
            sys.exit(1)
        # Check if elem has a section defined
        if elem not in sections:
            logCreator('ERROR', "Config File Error: %s has not SECTION defined" % elem)
            sys.exit(1)

#####################
#   Splunk Defs     #
#####################

def connectSplunk(config):
    logCreator('DEBUG','Trying to connect with client')
    try:
        service = client.connect( host=config.get('SPLUNK','HOST'), port=config.get('SPLUNK','PORT'),username=config.get('SPLUNK','USERNAME'),password=config.get('SPLUNK','PASSWORD'))
    except:
        print "Splunk error: Cannot connect with Splunk"
        logCreator('ERROR','"Splunk error: Cannot connect with Splunk"')
        exit(1)
    logCreator('DEBUG','Splunk service connected')
    return service

def getSearch(search,service):
    #print "/*Busqueda: " + search + "*/"
    # Retrieve the new search
    logCreator('INFO','Executing search of %s' % search)
    logCreator('DEBUG','Trying to get the new search')
    try:
        mysavedsearch = service.saved_searches[search]

    # Run the saved search
        job = mysavedsearch.dispatch()
    except:
        print "Error trying to connect Splunk"
        logCreator('ERROR','Splunk error: Splunk search %s not found' % search)
        sys.exit(1)
    logCreator('DEBUG','Search %s is OK' % search)

    # Create a small delay to allow time for the update between server and client
    sleep(2)

    # Wait for the job to finish--poll for completion and display stats
    while True:
        job.refresh()
        stats = {"isDone": job["isDone"],
                 "doneProgress": float(job["doneProgress"])*100,
                  "scanCount": int(job["scanCount"]),
                  "eventCount": int(job["eventCount"]),
                  "resultCount": int(job["resultCount"])}
        status = ("\r%(doneProgress)03.1f%%   %(scanCount)d scanned   "
                  "%(eventCount)d matched   %(resultCount)d results") % stats

        if stats["isDone"] == "1":
            break
        sleep(2)

    # Display the search results now that the job is done
    try:
        jobresults = job.results()
    except:
	print "Error: Invalid answer from Splunk"
        logCreator('ERROR','No valid answer from Splunk (Invalid licence?)')
        exit(1)

    #print jobresults

    # Finally, we got a reader and the number of results:
    answer = {}
    reader = results.ResultsReader(jobresults)
    answer['Reader'] = reader
    numResults= job["resultCount"]
    answer['Results'] = numResults

    return answer

def oneShot(search,service):

    # Call arguments
    kwargs_oneshot = {"earliest_time": "2014-10-20T12:00:00.000-07:00",
                  "latest_time": "2014-10-21T12:00:00.000-07:00",
                  "count": 0}

    # Execute search
    searchquery_oneshot = search
    oneshotsearch_results = service.jobs.oneshot(searchquery_oneshot, **kwargs_oneshot)

    # Get the results and display them using the ResultsReader
    reader = results.ResultsReader(oneshotsearch_results)

    # Finally, we got a reader and the number of results:
    answer = {}
    answer['Reader'] = reader
    return answer

#####################
#   DBs Defs        #
#####################

def getMongo(config):
    data = {}

    ip = config.get('MONGO','HOST')
    client = MongoClient(ip, 30000)

    try:
        db = client.push_notification_server
    except:
        logCreator('ERROR','Mongo error: Connection with mongo failed')
        exit(1)

    # Registered Terminals ->Which have a record in the database (never decreases)
    query_terminales = db.nodes.count()
    data['registered'] = query_terminales

    # Connected terminals: Which {co >=1}
    query_canales = db.nodes.find({ 'co': {'$gt': 0 }}).count()
    data['connected'] = query_canales

    return data

def date_format(date):
    str = date

    newSplit = str.split("T",1)
    modDate = newSplit[0]
    modHour = newSplit[1]


    newHour = modHour.split("+",1)[0]
    return modDate+" "+newHour.split(".",1)[0]

def showInsert(config,search,searchitem):

    # Select type and table
    type = config.get(search,'type')
    table = config.get(search,'table')
    searchResult = searchitem['Reader']

    # Counter to check empty searches
    counter = 0

    # String init
    tempquery = "INSERT INTO `%s` VALUES " % table

    if type is "1":
        for key in searchResult:
            counter += 1
            for info in key:
                if not info.startswith("_"):
                    tempquery = tempquery + "('%s',%s)," % (date_format(key["_time"]),key[info])

    if type is "8":
        yesterday = date.today() - timedelta(1)
        today = yesterday.strftime("%Y-%m-%d 00:00:00")
        for key in searchResult:
            counter += 1
            for info in key:
                if not info.startswith("_"):
                    tempquery = tempquery + "('%s',%s)," % (today,key[info])

    if type is "2":
        for key in searchResult:
            counter += 1
            for info in key:
                if not info.startswith("_"):
                    tempquery = tempquery + "('%s','%s',%s)," % (date_format(key["_time"]),info,key[info])

    # MNC special case
    if type is "4":
        for key in searchResult:
            counter += 1
            for info in key:
                try:
                    if not info.startswith("_"):
                        mcc = info.split('-')[0]
                        mnc = info.split('-')[1]
                        tempquery = tempquery + "('%s','%s','%s',%s)," % (date_format(key["_time"]),mcc,mnc,key[info])
                except:
                    logCreator('WARNING','Invalid mcc found: %s' % info)
                    # print "---------------> Hubo un error con %s" % info
                    # print "('%s','%s','%s',%s)," % (date_format(key["_time"]),mcc,mnc,key[info])

    if type is "5":
           queries = getMongo(config)
           registered = queries['registered']
           connected = queries['connected']
           for key in searchResult:
            counter += 1
            for info in key:
                if not info.startswith("_"):
                    tempquery = tempquery + "('%s',%s,%s,%s)," % (date_format(key["_time"]),str(registered),str(connected),key[info])

    # Delete last ,
    if counter is 0:
        logCreator('WARNING','Result is empty')
        exit(1)

    print tempquery[:-1] + ";"

    # Fin del script
    # return ans

def logInsert(config,search,reader,entradas):
    type = config.get(search,'type')
    table = config.get(search,'table')
    timerecord = "NONE"

    # Log if search is empty
    if entradas == '0': 
        logCreator('WARNING','Search %s is empty' % search)

    if type is "1":
           start="INSERT INTO "+ table +" VALUES "
           next=""
           if entradas == '0':
               today = date.today().strftime("%Y-%m-%d 00:00:00")
               next += "('"+today+"',NULL"+"), "
           else:
               for item in reader:
                   for data in item:
                       if (data != "_time") & (data != "_span") & (data != "_spandays"):
                           next += "('"+date_format(item["_time"])+"',"+(item[data])+"), "
                       else:
                           timerecord = date_format(item["_time"])
                #next += "('"+date_format(item["_time"])+"',"+(item["1"])+"), "

    if type is "2":
           start="INSERT INTO " + table +  " VALUES "
           next=""
           #### Changeme #####
           if entradas == '0':
               today = date.today().strftime("%Y-%m-%d")
               next += "('"+today+"',NULL"+",NULL"+"), "
           else:
               for item in reader:
                   for ip in item:
                       if (ip != "_time") & (ip != "_span") & (ip != "_spandays"):
                           next += "('"+date_format(item["_time"])+"','"+ip+"',"+item[ip]+"), "
                       else:
                           timerecord = date_format(item["_time"])

    if type is "3":
        start="INSERT INTO " + table +  " VALUES "
        yesterday = date.today() - timedelta(1)
        if entradas == '0':
            next += "('" + yesterday +" 00:00:00" +"',NULL"+"), "
            timerecord = yesterday +" 00:00:00"
        else:
            for item in reader:
                next="("
                next += "'"+ yesterday.strftime('%Y-%m-%d') + " 00:00:00" +  "',"
                for data in item:
                    if (data != "_time") & (data != "_span") & (data != "_tc") & (data != "date_mday"):
                        next += item[data]+','
                next = next[:-1] + "), "


    if type is "4":
        start="INSERT INTO " + table +  " VALUES "
        next = ""
        if entradas == '0':
            datecustom = datetime.datetime.now() - datetime.timedelta(minutes=60)
            today = datecustom.strftime("%Y-%m-%d %H:00:00")
            #today = date.today().strftime("%Y-%m-%d")
            next += "('"+today+"',NULL"+",NULL"+"), "
        else:
            for item in reader:
                #next+="("
                for data in item:
                    #if data == '_time':
                    #    next += "'"+date_format(item["_time"]) + "',"
                    if (data != "_time") & (data != "_span") & (data != "_spandays"):
                        if data == "NULL":
                            mcc = "NULL"
                            mnc = "NULL"
                        else:
                            mcc = data.split('-')[0]
                            mnc = data.split('-')[1]
                        next += "(" + "'"+date_format(item["_time"]) + "','" + mcc + "','" + mnc + "'," +  (item[data]) + ") ,"
                    else:
                        timerecord = date_format(item["_time"])
                next = next[:-1] + ", "

    if type is "5":
           queries = getMongo(config)
           start="INSERT INTO "+ table +" VALUES "
           registered = queries['registered']
           connected = queries['connected']
           next=""
           if entradas == '0':
               datecustom = datetime.datetime.now() - datetime.timedelta(minutes=60)
               today = datecustom.strftime("%Y-%m-%d %H:00:00")
               next += "('" + today + "'," + str(registered) + "," +  str(connected) + "," + "NULL" + "), "
           else:
               for item in reader:
                   for data in item:
                       if (data != "_time") & (data != "_span") & (data != "_spandays"):
                           # Active terminals: Which have received at least 1 notification in the last 24 hours
                           next += "('" + date_format(item["_time"]) + "'," + str(registered) + "," +  str(connected) + "," + (item[data]) + "), "
                       else:
                           timerecord = date_format(item["_time"])
    if type is "6":
           start="INSERT INTO "+ table +" VALUES "
           next=""
           if entradas == '0':
               today = date.today().strftime("%Y-%m-%d")
               next += "('"+today+",NULL"+",NULL"+",NULL"+"), "
               timerecord = today
           else:
               next += "('"+date_format(item["_time"])+"',"+ "NULL" +"), "
               timerecord = date_format(item["_time"])

    if type is "7":
           start="INSERT INTO "+ table +" VALUES "
           next=""
           if entradas == '0':
               datecustom = datetime.datetime.now() - datetime.timedelta(minutes=60)
               today = datecustom.strftime("%Y-%m-%d %H:00:00")
               #today = date.today().strftime("%Y-%m-%d")
               next += "('"+today+"',NULL"+' ,NULL'+"), "
           else:
               for item in reader:
                   for data in item:
                       if (data != "_time") & (data != "_span"):
                           next += "('"+date_format(item["_time"])+"', '"+data+"',"+(item[data])+"), "
                       else:
                           timerecord = date_format(item["_time"])
                #next += "('"+date_format(item["_time"])+"',"+(item["1"])+"), "

    #ans = start+next[:-2]+";"
    #logCreator('INFO',"INSERT table = %s search = %s" % table, search )
    if type is "8":
           start="INSERT INTO "+ table +" VALUES "
           next=""
           yesterday = date.today() - timedelta(1)
           today = yesterday.strftime("%Y-%m-%d 00:00:00")
           if entradas == '0':
               next += "('"+today+"',NULL"+"), "
           else:
               for item in reader:
                   for data in item:
                       if (data != "_time") & (data != "_span") & (data != "_spandays"):
                           next += "('"+today+"',"+(item[data])+"), "
                       else:
                           timerecord = today

    ans = start+next[:-2]+";"
    logmessage = "INSERT table = " + table + "search = " + search
    logCreator('INFO', logmessage )
    logCreator('INFO','Search Time=%s, table=%s' % (timerecord,table))
    return ans

def logStarter(config):
    logFile = config.get('LOGGING','FILE')
    logMode = config.get('LOGGING','LEVEL')
    # lofFormat = config.get('LOGGING','FORMAT')
    logFormat = '[KPIS # %(levelname)s] - {%(asctime)-15s} - %(message)s'

    if logMode == 'DEBUG':
        logging.basicConfig(filename=logFile,level=logging.DEBUG,format=logFormat)
    elif logMode == 'INFO':
        logging.basicConfig(filename=logFile,level=logging.INFO,format=logFormat)
    elif logMode == 'WARNING':
        logging.basicConfig(filename=logFile,level=logging.WARNING,format=logFormat)
    elif logMode == 'ERROR':
        logging.basicConfig(filename=logFile,level=logging.ERROR,format=logFormat)

def logCreator(level,message):
    if level == 'DEBUG':
        logging.debug(message)
    elif level == 'INFO':
        logging.info(message)
    elif level == 'WARNING':
        logging.warning(message)
    elif level == 'ERROR':
        print "Error! Check log file."
        logging.error(message)

# Example: earliest="01/14/2015:09:00:00" latest="01/14/2015:10:00:00" 
def customSearch(search,start,end):
    search = search.replace("-1h@h",start)
    search = search.replace("+0h@h",end)
    search = search.replace("-1d@d",start)
    search = search.replace("+0d@d",end)
    return search
