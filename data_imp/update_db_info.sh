#!/bin/bash

sed -i '29d' project.mml
sed -i '29a\    host: "172.16.1.191"' project.mml
sed -i '29a\    port: "5432"' project.mml
sed -i '29a\    user: "postgres"' project.mml
sed -i '29a\    password: "botech123"' project.mml
sed -i '29a\    dbname: "gis"' project.mml

