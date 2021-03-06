#!/bin/sh

BRIDGE=$(${SED-sed} -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev)

killall dhcpcd{,-bin} 2>/dev/null

IFACE=` sed '1d; /^w/ { s|:.*||p }' -n /proc/net/dev` 
KEY="off"
NET="public1@schreyer.org"

iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" essid "$NET"
ifconfig "$IFACE" 0 up

dhcpcd "${BRIDGE:-$IFACE}"
