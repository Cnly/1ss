#! /bin/sh

cat << EOF >> /docker/proxychains.conf
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0
localnet 127.0.0.0/255.0.0.0
EOF

cat << EOF >> /etc/apt/apt.conf
Acquire::http::proxy "http://127.0.0.1:8123";
Apt::Sandbox::Seccomp "false";
EOF

sed -i 's/http:\/\/mirrors.tuna.tsinghua.edu.cn/http:\/\/archive.ubuntu.com/' /etc/apt/sources.list
sed -i 's/http:\/\/mirrors.tuna.tsinghua.edu.cn/http:\/\/deb.debian.org/' /etc/apt/sources.list

cat /etc/proxychains.conf >> /docker/proxychains.conf

mv /docker/proxychains.conf /etc/
