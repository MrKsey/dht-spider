#
# Bittorrent dht network spider
#

FROM ubuntu:latest

ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_PASSWORD=""

ENV ADD_MAGNET=false
ENV ADD_RETRACKERS=false

COPY start.sh /start.sh
COPY upnp_dht.sh /upnp_dht.sh

RUN export DEBIAN_FRONTEND=noninteractive \
&& chmod a+x /start.sh && chmod a+x /upnp_dht.sh \
&& export GOPATH=/gocode && mkdir -p ${GOPATH}/bin && export PATH=$PATH:$GOPATH/bin \
&& apt-get update && apt-get upgrade -y \
&& apt-get install --no-install-recommends -y ca-certificates wget git jq curl golang iproute2 miniupnpc gridsite-clients cron software-properties-common gpg-agent \
&& add-apt-repository -y ppa:redislabs/redis && apt-get update && apt-get install --no-install-recommends -y redis-tools \
&& go install github.com/shiyanhui/dht/sample/spider@latest \
&& apt-get purge -y -q --auto-remove git golang software-properties-common gpg-agent \
&& apt-get clean \
&& touch /var/log/cron.log \
&& ln -sf /proc/1/fd/1 /var/log/cron.log

ENTRYPOINT ["/start.sh"]
