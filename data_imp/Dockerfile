FROM ubuntu:20.04

# Set up environment
ENV TZ=UTC
ENV AUTOVACUUM=on
ENV UPDATES=disabled
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PG_HOST=localhost \
    PG_PORT=5432 \
    PG_USER=postgres \
    PG_PASSWORD=123456 \
    PG_DBNAME=gis \
    OSM_FILE_NAME=taiwan-latest.osm.pbf

# Install dependencies
RUN apt-get clean && apt-get update \
    && apt-get install -y wget gnupg2 lsb-core apt-transport-https ca-certificates curl vim \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb [ trusted=yes ] https://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && apt-get install -y --no-install-recommends \
    postgis postgresql-12 postgresql-contrib-12 postgresql-server-dev-12 osm2pgsql git-core \
    python3-pip python3-setuptools gdal-bin libgdal-dev \
    && pip3 install wheel pyyaml requests psycopg2-binary --upgrade 

# createdb gis
# CREATE EXTENSION postgis; CREATE EXTENSION hstore;

WORKDIR /usr/osm
COPY . .
RUN git clone https://gitee.com/xuhj2015/openstreetmap-carto.git \
    && cd openstreetmap-carto \
    && git checkout v5.3.1 \
    && sed -i '103,111d' scripts/get-external-data.py