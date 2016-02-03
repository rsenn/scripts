DHCP_PID=`pgrep -f dhc`

if [ -n "$DHCP_PID" ]; then
  kill $DHCP_PID
  sleep 1
  kill -9 $DHCP_PID
fi

ALL_IFACES=`ifconfig -a| ${SED-sed} -n 's,^\([^ ]\+\).*,\1,p'`

for IFACE in $ALL_IFACES; do
  ifconfig $IFACE 0
  ifconfig $IFACE down
done

ifconfig lo 127.0.0.1 up

IFACE=$(grep '' -a -r /sys/class/net/eth*/carrier | ${SED-sed}  -n "s|.*/\([^/]\+\)/carrier:1|\1|p")

ifconfig $IFACE 0 up
#dhclient -4 $IFACE
dhcpcd $IFACE

echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 4.2.2.1" >/etc/resolv.conf
