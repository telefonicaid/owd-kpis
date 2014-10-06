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

#####################
#   Script Defs     #
#####################

def getArgs():
    parser = argparse.ArgumentParser(description='Collect data from Splunk and Mongo and store the info in the KPIs database.')
    parser.add_argument('-H', "--hourly", action ='store_true', help='Execute the searches hourly')
    parser.add_argument('-D', "--daily", action ='store_true', help='Execute the searches daily')
    args = parser.parse_args()
    return args

def check_config(config,searchList,frequency):
    if frequency.hourly:
        searches=config.get('SEARCH','IDhourly').split(',')
    elif frequency.daily:
        searches=config.get('SEARCH','IDdaily').split(',')
    else:
        logCreator('ERROR',"Frequency left")
        exit(1)

    sections=config.sections()

    # Check if each search has his section defined or exist in Splunk server
    for elem in searches:
        if elem in " ":
            #print "Config File Error: ID empty"
            logCreator('ERROR',"Config File Error: ID empty")
            sys.exit(1)
        if elem not in sections:
            #print "Config File Error: " + elem + " section does not exits."
            logCreator('ERROR', "Config File Error: " + elem + " section does not exits.")
            sys.exit(1)
        if elem not in searchList:
            #print "Config File Error: " + elem + " does not exists in Splunk"
            logCreator('ERROR',"Config File Error: " + elem + " does not exists in Splunk")
            sys.exit(1)

#####################
#   Splunk Defs     #
#####################

def connectSplunk(config):
    logCreator('DEBUG','Trying to connect with client')
    try:
        service = client.connect( host=config.get('SPLUNK','HOST'), port=config.get('SPLUNK','PORT'),username=config.get('SPLUNK','USERNAME'),password=config.get('SPLUNK','PASSWORD'))
    except:
        # print "Splunk error: Cannot connect with Splunk"
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

#def writeMysql(config,search,reader,entradas):
#    # Get Data
#    host = config.get('MYSQL','HOST')
#    db = config.get('MYSQL','DB')
#    user = config.get('MYSQL','USER')
#    pas = config.get('MYSQL', 'PASS')

def date_format(date):
    str = date

    newSplit = str.split("T",1)
    modDate = newSplit[0]
    modHour = newSplit[1]


    newHour = modHour.split("+",1)[0]
    return modDate+" "+newHour.split(".",1)[0]

def logInsert(config,search,reader,entradas):
    type = config.get(search,'type')
    table = config.get(search,'table')

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
                       if (ip != "_time") & (ip != "_span"):
                           next += "('"+date_format(item["_time"])+"','"+ip+"',"+item[ip]+"), "

    if type is "3":
        start="INSERT INTO " + table +  " VALUES "
        yesterday = date.today() - timedelta(1)
        if entradas == '0':
            next += "('" + yesterday +" 00:00:00" +"',NULL"+"), "
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
                           #next += "('" + date_format(item["_time"]) + "'," + str(registered) + "," +  str(connected) + "," + (item[data]) + "), "
                           next += "('" + date_format(item["_time"]) + "'," + str(registered) + "," + (item[data]) + "," + str(connected) + "), "
    if type is "6":
           start="INSERT INTO "+ table +" VALUES "
           next=""
           if entradas == '0':
               today = date.today().strftime("%Y-%m-%d")
               next += "('"+today+",NULL"+",NULL"+",NULL"+"), "
           else:
               next += "('"+date_format(item["_time"])+"',"+ "NULL" +"), "

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
                #next += "('"+date_format(item["_time"])+"',"+(item["1"])+"), "

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

    #ans = start+next[:-2]+";"
    #logCreator('INFO',"INSERT table = %s search = %s" % table, search )

    ans = start+next[:-2]+";"
    logmessage = "INSERT table = " + table + "search = " + search
    logCreator('INFO', logmessage )
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
