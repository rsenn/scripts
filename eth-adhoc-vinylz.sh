#!/bin/sh

. /usr/lib/sh/util.sh
. /usr/lib/sh/str.sh
. /usr/lib/sh/NET/if.sh

set -- `pgrep -f dhcp.*eth0`
test "$#" -gt 0 && killall -9 

ifconfig eth0 down
ifconfig eth0 10.5.5.1 netmask 255.255.255.224 broadcast 10.5.5.31 up

sv stop dnscache dnscachex
sv start dnscache dnscachex
sv stat dnscache dnscachex

/etc/init.d/dhcp3-server stop
/etc/init.d/dhcp3-server start
/etc/init.d/dhcp3-server status

set -- `if_get_addr wlan0`; EXTIP=$1

msg "wlan0 ip=$EXTIP"

# Set ACCEPT policy on each chain
iptables-restore <<__EOF__
*nat
:PREROUTING ACCEPT
:POSTROUTING ACCEPT
:OUTPUT ACCEPT 
COMMIT
*filter
:INPUT ACCEPT 
:FORWARD ACCEPT
:OUTPUT ACCEPT
COMMIT
__EOF__

# Enable IP forwarding

echo 1 >/proc/sys/NET/ipv4/ip_forward

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

