#!/bin/bash

pg_host=$PG_HOST
pg_port=$PG_PORT
pg_username=$PG_USER
pg_password=$PG_PASSWORD
pg_database=$PG_DBNAME

sed -i '29d' project.mml
sed -i '29a\    host: "$pg_host"' project.mml
sed -i '29a\    port: "$pg_port"' project.mml
sed -i '29a\    user: "$pg_username"' project.mml
sed -i '29a\    password: "$pg_password"' project.mml
sed -i '29a\    dbname: "$pg_database"' project.mml


sed -i '193a\    keepalives=1, keepalives_idle=30, keepalives_interval=10, keepalives_count=5,' scripts/get-external-data.py

