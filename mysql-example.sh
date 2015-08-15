#!/bin/bash

source /usr/lib/sh/util.sh
source /usr/lib/sh/array.sh

mysql_server="db01.adfinis.com"
mysql_database="test"
mysql_user="blah"
mysql_pass="********"

source mysql-functions.sh

IFS="
"

#echo "Tables:" $(mysql_tables)
#echo "Fields in clients: $(mysql_field_names "clients")"
#exit 0

mysql_field_names "clients"

#echo "${mysql_fields[@]}"
mysql_query "SELECT * FROM clients"

#for row in "${mysql_result[@]}"
#do
#  echo "$row"
#done
