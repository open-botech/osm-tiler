#!/bin/bash

sed -i '29d' project.mml
sed -i '29a\    host: "10.10.10.7"' project.mml
sed -i '29a\    port: "5432"' project.mml
sed -i '29a\    user: "postgres"' project.mml
sed -i '29a\    password: "123456"' project.mml
sed -i '29a\    dbname: "gis"' project.mml
