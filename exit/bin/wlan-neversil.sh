#!/bin/sh

BRIDGE=$(${SED-sed} -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev)

killall dhcpcd{,-bin} 2>/dev/null

IFACE="wlan0"
KEY="123456789012"
NET="pm5"

iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" essid "$NET"
ifconfig "$IFACE" 0 up

dhcpcd -dd -p -R "${BRIDGE:-$IFACE}"
