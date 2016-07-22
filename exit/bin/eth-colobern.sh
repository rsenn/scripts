#!/bin/sh

ifconfig eth0 down
ifconfig eth0 212.103.74.51 netmask 255.255.255.240 broadcast 212.103.74.63 up

route add default gw 212.103.74.49

cat >/etc/resolv.conf <<EOF
search adfinis.com
nameserver 212.103.64.17
EOF
