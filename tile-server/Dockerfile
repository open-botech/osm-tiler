FROM node:12


ENV PG_HOST=192.168.43.237 \
    PG_PORT=5432 \
    PG_USER=postgres \
    PG_PASSWORD=123456 \
    PG_DBNAME=postgres

COPY update_db_info.sh /

RUN apt-get clean && apt-get update --fix-missing && apt-get upgrade -y --no-install-recommends --allow-unauthenticated && apt-get install -y --no-install-recommends --allow-unauthenticated \
  fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted fonts-hanazono ttf-unifont \
  && rm -rf /var/lib/apt/lists/*

RUN npm install && npm install mapnik connect sphericalmercator express generic-pool silly-datetime cors

RUN mkdir -p /home/openstreetmap-carto-src \
  && cd /home/openstreetmap-carto-src \
  && git clone --branch v5.3.1 https://gitee.com/xuhj2015/openstreetmap-carto.git  \
  # && git clone --branch v5.3.1 https://github.com/gravitystorm/openstreetmap-carto.git  \
  && cd openstreetmap-carto \
  && sh /update_db_info.sh \
  && npm install -g carto \
  && carto project.mml > /mapnik.xml \
  && cp -r ./symbols / \
  && rm -rf /home/openstreetmap-carto-src 


WORKDIR /usr/src/app
COPY . .

EXPOSE 3000
CMD [ "node", "html/server.js" ]