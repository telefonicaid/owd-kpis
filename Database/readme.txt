

To deploy kpis_database follow these steps carefully.

1-. Create database

2-. Create tables
    ->	mysql -h dBHost -u dBUser dBName -p < aggregation_model.sql 

3-. Populate tables, follow the order
    -> mysql -h dBHost -u dBUser dBName -p < insert_table_aliasServidoresApp.sql
    -> mysql -h dBHost -u dBUser dBName -p < insert_table_operator.sql
    -> mysql -h dBHost -u dBUser dBName -p < insert_table_ncc.sql

Then you have kpis_db populated



