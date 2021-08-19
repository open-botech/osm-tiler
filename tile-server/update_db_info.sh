#!/bin/bash

sed -i '29d' project.mml
sed -i '29a\    host: "10.10.10.7"' project.mml
sed -i '29a\    port: "5432"' project.mml
sed -i '29a\    user: "postgres"' project.mml
sed -i '29a\    password: "123456"' project.mml
sed -i '29a\    dbname: "gis"' project.mml

sed -i '193a\    keepalives=1, keepalives_idle=30, keepalives_interval=10, keepalives_count=5,' scripts/get-external-data.py

