#!/bin/sh
CONFIG="$HOME/wpa_supplicant.conf"
IF=`iwconfig 2>&1 |grep IEEE.802 | sed 's,\s.*,,'`

if [ "$1" = "-l" ]; then
	ifconfig $IF up
  iwlist $IF scanning|grep ESSID|sed 's,:",=", ;s,^\s*,, ; s,ESSID="\(.*\)",\1,'           
  exit $?
fi

ESSID=$1
PASS=$2
IP=$3

if [ $# -gt 1 ]; then
  CONFIG=`mktemp -p /tmp/ wpa_supplicant.conf-XXXXXX` 
  trap 'rm -f "$CONFIG"' EXIT
  wpa_passphrase "$ESSID" "$PASS" >"$CONFIG"||exit $?
fi

set -x

killall wpa_supplicant dhcpcd dhclient pump
sleep 1
killall -9 wpa_supplicant dhcpcd dhclient pump
ifconfig $IF down
ifconfig $IF 0 up
wpa_supplicant -i ${IF} -c "$CONFIG" -B

if [ -n "$IP" ]; then
	ifconfig ${IF} ${IP} up
  route add default gw ${IP%.[0-9]*}.1
else

 dhcpcd -d ${IF}
fi

cat >/etc/resolv.conf <<EOF
nameserver 8.8.4.4
nameserver 8.8.8.8
nameserver 4.2.2.1
search workgroup
EOF

sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o $IF -j MASQUERADE

