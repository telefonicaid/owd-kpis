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
    splunkList = service.saved_searches
    check_config(config,splunkList,args)


    # Get our Searchlist
    if args.hourly:
        searchlist=config.get('SEARCH','IDhourly').split(',')
    elif args.daily:
        searchlist=config.get('SEARCH','IDdaily').split(',')
    else:
        print "Extractor error: No mode defined (-D or -H)."
        exit(1)

    # Get mode and output
    debug = config.get('MODE','debug')
    output = config.get('MODE','output')

    # For each local search
    for search in searchlist:

        # Search Item in Splunk
        searchitem = getSearch(search,service)
 
        # DEBUG not enabled
        if debug is '0':
            # Log the Inserts
            if output == 'log':
                print logInsert(config,search,searchitem['Reader'],searchitem['Results'])
            if output is 'mysql':
                writeMysql(config,search,searchitem['Reader'],searchitem['Results'])
        # DEBUG enabled
        else:
            print searchitem

    logCreator('INFO','******* Finalized API-MONGO extractor. ********')
