#! /bin/bash

start-stop-daemon --exec $(which ss-local) -bS -- -c /docker/ss-config.json
start-stop-daemon --exec $(which polipo) -bS

# export LD_PRELOAD=/usr/lib/libproxychains4.so
# export PROXYCHAINS_CONF_FILE=/etc/proxychains.conf
# export PROXYCHAINS_QUIET_MODE=1

export HTTP_PROXY=http://127.0.0.1:8123
export HTTPS_PROXY=http://127.0.0.1:8123
export ALL_PROXY=http://127.0.0.1:8123
export NO_PROXY=127.0.0.1

exec proxychains4 -q $@
