#!/bin/bash

pg_host=$PG_HOST
pg_port=$PG_PORT
pg_username=$PG_USER
pg_password=$PG_PASSWORD
pg_database=$PG_DBNAME
osm_file_name=$OSM_FILE_NAME

osm2pgsql --create --database $pg_database -G -C 5000 ./$osm_file_name -H $pg_host -P $pg_port -U $pg_username -W --slim --hstore --hstore-add-index  --style openstreetmap-carto/openstreetmap-carto.style --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua

cd openstreetmap-carto

git checkout v5.3.1

psql -h $pg_host -p $pg_port -U $pg_username -W  -d $pg_database -f indexes.sql

python3 scripts/get-external-data.py -d $pg_database -U $pg_username -w $pg_password -H $pg_host -p $pg_port 
