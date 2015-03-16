#!/bin/bash -       
#title           :rastreator.sh
#description     :This script helps you to find data missing in kpis db.
#author		 :Eloisa Ibanez
#date            :20140617
#version         :0.0    
#usage		 :sh rastreator.sh
#==============================================================================

today=`date +%Y-%m-%d`
yesterday=`TZ=GMT+23 date '+%Y-%m-%d'`

hour=`date +%k`
database="kpis_db"
user="kpis"
password="push"


echo "INFORMES CADA HORA: "
echo "================== "

for table in "notificaciones_entrantes_agr" "notificaciones_entrantes_ncc_agr" "notificaciones_entregadas_agr" "peticiones_registros_agr" "terminales_agr"; do
	for j in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
		if [ "$j" -lt "$hour" ] ; then		
			time="$j:00:00"
			time="$today $time"
			data=`mysql -u $user -p$password $database -e "select * from $table where fecha='$time'"`
			if [ -z "$data" ] ; then
				echo "Hay un hueco el $time en la tabla $table de la bbdd $database"
			fi
		fi
	done		
done

echo "INFORMES DIARIOS: "
echo "================= "

for table in "terminales_con_registros_agr" "notificaciones_entrantes_agr_ld" "terminales_agr_ld" "terminales_agr_w" "terminales_agr_m" "notificaciones_entrantes_ncc_agr_ld"; do
        time="00:00:00"
        time="$yesterday $time"
        data=`mysql -u $user -p$password $database -e "select * from $table where fecha='$time'"`
        if [ -z "$data" ] ; then
                echo "Hay un hueco el $time en la tabla $table de la bbdd $database"
        fi
done


