#!/bin/bash

export GOPATH=/gocode && export PATH=$PATH:$GOPATH/bin

apt-get update && apt-get upgrade -y

ulimit -s 65535
ulimit -S unlimited

# Set alias for redis-cli
if [ -z "$REDIS_PASSWORD" ]; then
    alias redis-cli='redis-cli -h $REDIS_HOST -p $REDIS_PORT'
else
    alias redis-cli='redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD --no-auth-warning'
fi
shopt -s expand_aliases

# Create a new index schema
redis-cli FT.CREATE namesIdx ON JSON SCHEMA $.name AS name TEXT

# Download and encode retrackers list
export RETRACKERS_URL="shorturl.at/kowGM"
export RETRACKERS_LIST=""
if [ "$ADD_MAGNET" = "true" ] && [ "$ADD_RETRACKERS" = "true" ]; then
    wget --no-check-certificate $RETRACKERS_URL -O /retrackers.txt
    if [ -s /retrackers.txt ]; then
        for line in $(cat /retrackers.txt); do
            RETRACKERS_LIST+=\&tr\=$(urlencode "$line")
        done
    fi
fi

# Try to passthrough DHT port 6881/UDP to container
export DHT_PORT=6881
export MY_IP=$(ip route | grep -E "default via" | cut -d ' ' -f 7)
export UPDATE_SCHEDULE="0 */1 * * *"
/etc/init.d/cron stop
. /upnp_dht.sh
UPNP_OK=$(upnpc -L | grep -o -s -E "UDP.*$DHT_PORT")
if [ ! -z "$UPNP_OK" ]; then
    echo "UPnP Port Forwarding complete: $UPNP_OK"
    echo "$(echo "$UPDATE_SCHEDULE" | sed 's/\\//g' | sed "s/\"//g") /upnp_dht.sh >> /var/log/cron.log 2>&1" | crontab -
    cron -f >> /var/log/cron.log 2>&1&
else
    echo "UPnP Port Forwarding failed."
    echo "You must manually forward port $DHT_PORT to host $MY_IP on your router."
fi
echo " "
echo "=================================================="
echo " "

# Run DHT spider
spider | grep -v "^$" | while read line; do (\
export TORRENT_HASH=$(echo $line | jq -r .infohash); \
export TORRENT_INFO=$(echo $line | jq -r 'del(.infohash)'); \
export TORRENT_NAME=$(echo $TORRENT_INFO | jq -r .name 2>/dev/null); \
[ ! -z "$TORRENT_NAME" ] && redis-cli JSON.SET $TORRENT_HASH . "$TORRENT_INFO" &>/dev/null && echo -e "$TORRENT_HASH\t$TORRENT_NAME"; \
[ $REDIS_TTL -gt 0 ] && redis-cli EXPIRE $TORRENT_HASH $REDIS_TTL &>/dev/null; \
[ "$ADD_MAGNET" = "true" ] && [ ! -z "$TORRENT_NAME" ] \
&& export TORRENT_NAME=$(echo "$TORRENT_NAME" | jq -rR @uri) \
&& export MAGNET=\'\"$(echo magnet:?xt=urn:btih:$TORRENT_HASH\&dn=$TORRENT_NAME$RETRACKERS_LIST)\"\' \
&& echo "JSON.SET $TORRENT_HASH .magnet $MAGNET" | redis-cli &>/dev/null
); done
