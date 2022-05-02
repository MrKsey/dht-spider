# dht-spider
DHT is the name given to the Kademlia-based distributed hash table (DHT) used by BitTorrent clients to find peers via the BitTorrent protocol.  
DHT spider implements the bittorrent DHT protocol in crawling mode. The standard mode follows the BEPs, and you can use it as a standard dht server. The crawling mode aims to crawl as more metadata info as possiple. It doesn't follow the standard BEPs protocol. With the crawling mode, you can build another BitTorrent DHT search engine.

### More info:
- https://github.com/shiyanhui/dht

### Requrements:
Redis - in-memory data structure store used as a database for DHT spider.  
Install docker with redis:  
- create folder for database  
```
  mkdir -p /docker/redis && chmod -R 777 /docker/redis
```
- install redis docker
```
docker run --name redis -d --restart=unless-stopped -p 6379:6379 -v /docker/redis:/data redislabs/redismod \
--requirepass <password for redis> \
--dir /data \
--loadmodule /usr/lib/redis/modules/rejson.so \
--loadmodule /usr/lib/redis/modules/redisearch.so
```

### Installing DHT spider
```
docker run --name dht-spider -d --restart=unless-stopped -p 6881:6881 \
-e REDIS_PASSWORD=<password for redis> \
-e ADD_MAGNET=true \
-e ADD_RETRACKERS=true \
ksey/dht-spider
```
| Parameters | Description |
| --- | --- |
| `-p 6881:6881` | DHT spider port. Must passing through from router to dht spider container.  |
| `-e REDIS_HOST=localhost` | Redis database hostname |
| `-e REDIS_PORT=6379` | Redis database port (default: 6379) |
| `-e REDIS_PASSWORD=<password for redis>` | Redis password |
| `-e ADD_MAGNET=true` | Generate and add magnet link to dht object in database |
| `-e ADD_RETRACKERS=true` | Add list of retrackers to magnet link |
