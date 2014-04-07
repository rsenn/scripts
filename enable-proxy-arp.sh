#!/bin/sh
if [ "$#" -le 0 ]; then
  set -- all
fi
for INTERFACE; do
  sysctl net.ipv4.conf.${INTERFACE}.proxy_arp=1
done
