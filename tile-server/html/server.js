'use strict';

const express = require('express')
  , mapnik = require('mapnik')
  , mercator = require('sphericalmercator')
  , cors=require("cors")
  , fs = require('fs');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

mapnik.register_system_fonts(); 
mapnik.register_default_input_plugins();

// mapnik 线程池
var poolModule = require('generic-pool');
var pool = poolModule.createPool({
    create : function() {
      var map = new mapnik.Map(256, 256);
      map.loadSync('/mapnik.xml');
      return map;
    },
    destroy  : function(map) { map = null; }
  }, {
    max : 9,
    min : 9, 
    log : true 
});

// App
const app = express();
app.use(cors()); 

app.get('/', (req, res) => {
	fs.readFile('html/index.html', "utf-8", (err, data) => {
    if(err){
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end(err.message);
    }else{
      res.writeHead(200, { 'Content-Type': 'text/html' })
      res.end(data);
    }
  });
});

app.get('/html/:file', (req, res) => {
	fs.readFile('html/'+req.params['file'], "utf-8", (err, data) => {
    if(err){
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end(err.message);
    }else{
      res.writeHead(200, { 'Content-Type': 'application/octet-stream' })
      res.end(data);
    }
  });
});

app.get('/tile/:z/:x/:y', (req, res) => {
  // 从线程池获取map
  pool.acquire().then(function(map) {
    var z = req.params['z'], x = req.params['x'], y = req.params['y'];
    var merc = new mercator({size: 256});
    var bbox = merc.bbox(parseInt(x), parseInt(y), parseInt(z), false, '900913');
    map.zoomToBox(bbox);
    var img = new mapnik.Image(256, 256);
    // 渲染地图瓦片
    map.render(img, function (err, img) {
      pool.release(map);
      if (err) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end(err.message);
      } else {
        res.writeHead(200, {'Content-Type': 'image/png'});
        res.end(img.encodeSync('png'));
      }
    });
  })
  .catch(function(err) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end(err.message);
  });
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);