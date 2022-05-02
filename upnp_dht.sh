#!/bin/bash

# Try to passthrough DHT port 6881/UDP to container
export DHT_PORT=6881
export MY_IP=$(ip route | grep -E "default via" | cut -d ' ' -f 7)
upnpc -d $DHT_PORT UDP
upnpc -e "DHT spider" -a $MY_IP $DHT_PORT $DHT_PORT UDP
UPNP_OK=$(upnpc -L | grep -o -s -E "UDP.*$DHT_PORT")
if [ ! -z "$UPNP_OK" ]; then
    echo "UPnP Port Forwarding complete: $UPNP_OK"
else
    echo "UPnP Port Forwarding failed."
	echo "You must manually forward port $DHT_PORT to host $MY_IP on your router."
fi
