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
&& export GOPATH=/gocode && mkdir -p ${GOPATH}/bin && export PATH=$PATH:$GOPATH/bin \
&& apt-get update && apt-get upgrade -y \
&& apt-get install --no-install-recommends -y ca-certificates wget git jq curl software-properties-common iproute2 miniupnpc gridsite-clients cron gpg \
&& add-apt-repository -y ppa:longsleep/golang-backports && apt update && apt install --no-install-recommends -y golang-go \
&& curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list \
&& apt-get update && apt-get install --no-install-recommends -y redis-tools \
&& go install github.com/shiyanhui/dht/sample/spider@latest \
&& apt-get purge -y -q --auto-remove git golang-go software-properties-common gpg \
&& apt-get clean \
&& touch /var/log/cron.log \
&& ln -sf /proc/1/fd/1 /var/log/cron.log

ENTRYPOINT ["/start.sh"]
