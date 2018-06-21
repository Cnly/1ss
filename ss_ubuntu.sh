#!/usr/bin/env bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi


vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

echo "Deploying for Ubuntu..."

echo "Port: "
read PORT

if [ -z $PORT ]; then
    echo "PORT cannot be empty!"
    exit 1
fi

echo "Password (leave empty for random): "
read PASSWD

. /etc/lsb-release

vercomp $DISTRIB_RELEASE "16.04"

case $? in
    2)
        echo "You are using Ubuntu 16.04 or older, so we will use PPA"
    
        (apt install software-properties-common -y && add-apt-repository ppa:max-c-lv/shadowsocks-libev -y && apt update && apt install shadowsocks-libev) || {
            echo "Error occurred. Try again later."
            exit 1
        }
    ;;
    *)
        (apt update && apt -y install shadowsocks-libev) || {
            echo "Error occurred. Try again later."
            exit 1
        }
    ;;
esac

IP=`curl ipecho.net/plain`
if [ -z "$PASSWD" ]; then
    PASSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};`
fi

cat << EOF > /etc/shadowsocks-libev/okss.json
{
    "server":"0.0.0.0",
    "server_port":$PORT,
    "local_address": "127.0.0.1",
    "local_port":8010,
    "password":"$PASSWD",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": true
}
EOF

cat << EOF > /etc/sysctl.d/local.conf
# SS Optimization
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1

# for high-latency network
# net.ipv4.tcp_congestion_control = hybla

# for low-latency network, use cubic instead
# net.ipv4.tcp_congestion_control = cubic
EOF

sysctl --system

systemctl start shadowsocks-libev-server@okss.service

echo "DONE!"
echo "-----CONFIG FILE FOR CLIENTS BELOW-----"

cat /etc/shadowsocks-libev/okss.json | sed "s/0.0.0.0/$IP/g"
