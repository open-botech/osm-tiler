# 项目说明
基于OSM、mapnik、node的地图服务，相对于openstreetmap-tile-server更简洁易懂，可操作性更强。

#### 为什么会有my-osm-tiler这个项目
```
之前使用的是openstreetmap-tile-server，是开源的，但是里面存着一些优化点。
1、PG库在镜像里面，虽然可以数据外挂，但是看不到数据库里面的数据。
2、不会C++，openstreetmap-tile-server使用了mod_tile，mod_tile是C++写的，集成了Apache，并且多线程调用mapnik渲染瓦片。
在之前使用openstreetmap-tile-server的时候，发现了一些问题，由于知识盲区，所以无法排查问题。
之前出现的问题的现象是瓦片加载不出来，原因80%是mod_tile多线程调用mapnik渲染瓦片的时候卡住了，20%是Apache代理瓦片卡住了。
```
#### my-osm-tiler原理
```
1、my-osm-tiler是参考openstreetmap-tile-server实现的，除了核心组件mapnik、openstreetmap-carto、osm2pg外，其他组件都换成我们熟悉的，比如node、nginx。
2、因为数据导入和瓦片渲染服务本身就是串行的两个过程，而数据导入只需要执行一次就可以了。
同时数据导入过程非常漫长，所以把数据导入做成脚本将数据导入的三个主要步骤可以同时执行，也可以分别执行，所以my-osm-tiler把数据导入和瓦片渲染服务分开了。

data_imp（数据导入）的主要功能：
    1、数据导入，主要是通过osm2pg将osm数据导入到PG库中，然后根据carto的需求，建立数据索引，同时导入其他carto需要的数据。
    2、为了保证osm2pg和python的运行环境，将数据导入脚本放到了docker镜像中，利用docker容器保证运行环境。

tile_server（瓦片渲染服务）的主要功能：
    1、编译carto的样式文件，作为mapnik的样式。（样式文件中包含了大量sql及PG库的地址）
    2、利用node-mapnik将PG库中的数据渲染成瓦片，提供http服务供业务系统调用。

整体的流程：
    pbf ——osm2pg——> PG库 ——mapnik、carto——> 瓦片
```

# 项目部署启动
#### 环境变量
```
PG_HOST：PG库的IP
    data_imp和tile_server两个容器启动的时候都需要
PG_PORT：PG库的端口，默认5432
    data_imp和tile_server两个容器启动的时候都需要
PG_USER：PG库的用户名，默认postgres
    data_imp和tile_server两个容器启动的时候都需要
PG_PASSWORD：PG库的密码，默认123456
    data_imp和tile_server两个容器启动的时候都需要
PG_DBNAME：PG库的数据库名，默认postgres
    data_imp和tile_server两个容器启动的时候都需要
OSM_FILE_NAME：osm文件名
    data_imp容器启动的时候都需要，tile_server不需要
```
#### data_imp
```
制作镜像：docker build -t data_imp:v1 .
容器启动：docker run -e PG_HOST:xxx -d -it data_imp:v1         (要加-it，可以不加端口和容器名，用完一次就不用了)
进入容器：docker exec -it 容器ID /bin/bash
运行脚本：sh data_imp.sh        
    中间需要输入两次PG库的密码，执行时间非常长，等着就行。
    脚本中主要有三条命令，第一条是将pbf数据导入到PG中，结果是PG中出现一堆planet_osm开头的表，
    第二条是建立索引，控制台会出现大概7-8条“CREATE INDEX”的字符串， 
    第三条是下载并导入carto需要的其他数据，结果是PG库中出现了一堆非planet_osm开头的表)  

最后：在第三条命令中的python脚本会执行postgresql的“VACUUM analyze”功能，但是执行的时候会出现事务问题，因此在dockerfile下载完openstreetmap-carto后把相关逻辑删除了。
所以可以在data_imp.sh脚本执行完成后，手动执行“VACUUM analyze 表名”操作。
```

#### tile_server：
```
制作镜像：docker build -t map_tiler:v1 .
容器启动：docker run -e PG_HOST:xxx -d --name osm-tiler -p 3000:3000 map_tiler:v1 
    为了不会每次渲染瓦片的时候都加载样式，加载样式比较非常慢，所以使用了线程池，在服务启动、创建线程时加载mapnik样式，所以花费的时间比较长。
    看到“Running on http://0.0.0.0:3000”表示启动成功。
```
#### demo
```
demo里面放了 一个nginx配置文件和一些前端demo文件。
nginx文件中除了服务代理外，主要做了瓦片的缓存。可以加快瓦片响应时间，降低tile_server压力。
前端demo文件是通过maptalks对瓦片服务进行调用和展示。
```

# 代办
```
pbf数据实际上是可以更新的，现在没加更新的逻辑
```






