#!/bin/bash

####### Crontab:
#5 * * * * /home/operaciones/script/load_hourly.sh
#5 0 * * * /home/operaciones/script/load_daily.sh

PYTHONPATH=/home/operaciones/script/lib/splunk-sdk-python:/usr/lib/python2.6/site-packages:/home/operaciones/script/lib/argparse-1.2.1:/home/operaciones/script/lib/SQLAlchemy-0.9.3:/home/operaciones/script/lib/SQLAlchemy.egg-info:/home/operaciones/script/lib/pymongo:/home/operaciones/script/lib/ordereddict-1.1
export PYTHONPATH

#### PATH #####
LOG_FILE='/home/operaciones/script_NV/log/load_daily.log'
PATH_EXE=/home/operaciones/script_NV/bin
PATH_EXE_DATA=/home/operaciones/script_NV/data/SQL_outputs
SQL_SCRIPT=/home/operaciones/script_NV/data/SQL_outputs/salidadaily.sql
NO_PROCESADO="/home/operaciones/script_NV/data/kpis-no-procesados"
MYSQL_USER="kpis"
MYSQL_PASS="push"

### Changeme
DB=test
###########

SAVE=$1

 log() {
  echo "[`date +%Y%m%d-%H:%M:%S`] $1"
  echo "[`date +%Y%m%d-%H:%M:%S`] $1" >> "$LOG_FILE"
}

no_procesado(){

   log "Moviendo fichero a home de operaciones"
   fich="no-procesado-$RANDOM-`date +%s`.sql"
   cp $1 $NO_PROCESADO/$fich
   # chown -R operaciones.operaciones /home/operaciones

}

dump_data_to_mysql()
{
file_inserts="$1"
inserciones=`cat "$file_inserts"|wc -l `
log "lineas a insertar:$inserciones"
mysql --user=$MYSQL_USER --password=$MYSQL_PASS $DB -e "show tables" >/dev/null
mysql_OK=$?
log "valor de ok:$mysql_OK"
if [ "$mysql_OK" -eq 0 ]; then
        log "status mysql Ok"
                if [ -f $file_inserts ]; then
                    mysql --user=$MYSQL_USER --password=$MYSQL_PASS $DB < $file_inserts
		    mysql_OK=$?
		    if [ "$mysql_OK" -eq 1 ]; then
		        no_procesado $file_inserts
			log "Ocurrio algun problema al insertar"
		    else
                    log "fin insertar"
		    fi
                else
                    log "no hay datos que insertar"
            fi
else
    #copiamos el fichero a $NO_POCESADO
    no_procesado $file_inserts
    log "La base de datos no esta lista"
fi
}


cd $PATH_EXE
#echo "load_daily.sh executed at `date`" >> load_daily.log
log "load_daily.sh executed at `date`"

python $PATH_EXE/api-extractor.py -D > $PATH_EXE_DATA/salidadaily.sql
#mysql -u kpis -ppush $DB < $PATH_EXE_DATA/salidadaily.sql
#rm $PATH_EXE/salidaPython.sql

dump_data_to_mysql $SQL_SCRIPT
