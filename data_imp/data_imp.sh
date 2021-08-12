#!/bin/bash

pg_host="10.10.10.7"
pg_port="5432"
pg_username="postgres"
pg_password="123456"
pg_database="gis"

osm2pgsql --create --database $pg_database -G -C 5000 ./china-latest.osm.pbf -H $pg_host -P $pg_port -U $pg_username -W --slim --hstore --hstore-add-index  --style openstreetmap-carto/openstreetmap-carto.style --tag-transform-script openstreetmap-carto/openstreetmap-carto.lua

cd openstreetmap-carto

git checkout v5.3.1

psql -h $pg_host -p $pg_port -U $pg_username -W  -d $pg_database -f indexes.sql

sed -i '103,111d' scripts/get-external-data.py

python3 scripts/get-external-data.py -d $pg_database -U $pg_username -w $pg_password -H $pg_host -p $pg_port 
