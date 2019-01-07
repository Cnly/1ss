#! /usr/bin/env bash

sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list
sed -i 's/http:\/\/deb.debian.org/http:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list
