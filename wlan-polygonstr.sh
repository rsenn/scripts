#!/bin/sh

#BRIDGE=$(sed -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev)

killall dhcpcd{,-bin} 2>/dev/null

IFACE="wlan0"
KEY="off"
NET="1413 7470"

iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" essid "$NET"
ifconfig "$IFACE" 0 up

dhclient "${BRIDGE:-$IFACE}"

#dhcpcd -dd -p -R "${BRIDGE:-$IFACE}"
