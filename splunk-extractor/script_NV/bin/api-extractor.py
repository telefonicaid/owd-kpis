#!/usr/bin/env python
##################################################################
#                                                                #
#   API extractor script. Remember:                              #
#     - Save you search in Splunk server                         #
#     - Edit the configuration file api-extractor.cfg            #
#                                                                #
################### by Eric Sanchez ##############################


import splunklib.client as client
from time import sleep
import sys
import splunklib.results as results
import ConfigParser
from apilib import *

CONFIG_FILE='api-extractor.cfg'

if __name__ == '__main__':

    # Get script arg
    args = getArgs()

    # Get Config File
    config = ConfigParser.ConfigParser()
    config.read(CONFIG_FILE)

    # Starting Logs
    logStarter(config)
    logCreator('INFO','******* Starting API-MONGO extractor. ********')

    # Connect with Splunk
    service = connectSplunk(config)
 
    # Check if everything is alright
    check_config(config,args)

    # Get our Searchlist
    if args.hourly or args.retryhourly:
        searchlist=config.get('SEARCH','IDhourly').split(',')
    elif args.daily or args.retrydaily:
        searchlist=config.get('SEARCH','IDdaily').split(',')
    else:
        print "Extractor error: No mode defined (-D or -H)."
        exit(1)

    # Get mode and output
    debug = config.get('MODE','debug')
    output = config.get('MODE','output')

    # For each local search
    for search in searchlist:

        # Get search string
        mysearch=config.get(search,'search')

        # Modify search string if retrying
        if args.retryhourly:
            mysearch = customSearch(mysearch,args.retryhourly[0],args.retryhourly[1])
        elif args.retrydaily:
            mysearch = customSearch(mysearch,args.retrydaily+":00:00:00",args.retrydaily+":23:59:59")

        # Search Item in Splunk
        searchitem = oneShot(mysearch,service)

        # DEBUG not enabled
        if debug is '0':

            # LOG Mode
            if output == 'log':
                showInsert(config,search,searchitem)

            # MySQL Mode
            if output is 'mysql':
                writeMysql(config,search,searchitem['Reader'],searchitem['Results'])
        # DEBUG enabled
        else:
            for item in searchitem['Reader']:
                print "Busqueda %s" % search
                print(item)


    logCreator('INFO','******* Finalized API-MONGO extractor. ********')
