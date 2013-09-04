#!/bin/sh

BRIDGE=$(sed -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev)

killall dhcpcd{,-bin} 2>/dev/null

IFACE="wlan0"
mode="managed"
enc="off"
KEY="off"
NET="linksys"
channel="11"
FREQ="2.462G"
ap="00:18:39:AB:FF:FA"

ifconfig "$IFACE" down

iwconfig "$IFACE" essid "$NET"
iwconfig "$IFACE" enc "$enc"
iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" FREQ "$FREQ"
iwconfig "$IFACE" channel "$channel"
iwconfig "$IFACE" ap "$ap"

ifconfig "$IFACE" 0 up

dhcpcd -dd -p -R "${BRIDGE:-$IFACE}"
