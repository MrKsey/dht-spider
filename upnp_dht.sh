#!/bin/bash

# Try to passthrough DHT port 6881/UDP to container
export DHT_PORT=6881
export MY_IP=$(ip route | grep -E "default via" | cut -d ' ' -f 7)
upnpc -d $DHT_PORT UDP
upnpc -e "DHT spider" -a $MY_IP $DHT_PORT $DHT_PORT UDP
