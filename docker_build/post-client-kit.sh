#! /bin/sh

cat << EOF >> /docker/proxychains.conf
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0
localnet 127.0.0.0/255.0.0.0
EOF

cat /etc/proxychains.conf >> /docker/proxychains.conf

mv /docker/proxychains.conf /etc/
