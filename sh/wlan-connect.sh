#!/bin/sh
CONFIG="$HOME/wpa_supplicant.conf"
IF=`iwconfig 2>&1 |grep IEEE.802 | ${SED-sed} 's,\s.*,,' |grep -v ^mon| head -n1`

if [ "$1" = "-l" ]; then
	ifconfig $IF up
  iwlist $IF scanning|grep ESSID|${SED-sed} 's,:",=", ;s,^\s*,, ; s,ESSID="\(.*\)",\1,'           
  exit $?
fi

ESSID=$1
PASS=$2
IP=$3

if [ $# -gt 1 ]; then
  CONFIG=`mktemp -p /tmp/ wpa_supplicant.conf-XXXXXX` 
  trap 'rm -f "$CONFIG"' EXIT
  wpa_passphrase "$ESSID" "$PASS" | tee "$CONFIG" | ${SED-sed} "s|^|$CONFIG: |" ||exit $?
fi

set -x

killall wpa_supplicant dhcpcd dhclient pump
sleep 1
killall -9 wpa_supplicant dhcpcd dhclient pump

route del default 2>/dev/null || ip route flush default

ifconfig $IF down 2>/dev/null || ip link delete $IF
ifconfig $IF 0 up 2>/dev/nul || ip link set dev $IF up 

wpa_supplicant -i ${IF} -c "$CONFIG" -B

if [ -n "$IP" ]; then
	ifconfig ${IF} ${IP} up 2>/dev/null || ip addr add ${IP} dev ${IF}
  route add default gw ${IP%.[0-9]*}.1 2>/dev/null || ip route replace to 0/0 via  ${IP%.[0-9]*}.1
else
 dhcpcd -d ${IF} || dhclient -v ${IF}
fi

cat >/etc/resolv.conf <<EOF
nameserver 8.8.4.4
nameserver 8.8.8.8
nameserver 4.2.2.1
search workgroup
EOF

for chain in INPUT FORWARD OUTPUT; do
	iptables -P $chain ACCEPT
done
iptables --flush

for chain in PREROUTING INPUT OUTPUT POSTROUTING; do
	iptables -t nat -P $chain ACCEPT
done
iptables -t nat --flush


sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o $IF -j MASQUERADE
