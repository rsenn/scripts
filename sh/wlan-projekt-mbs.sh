#!/bin/sh
NL="
"

BRIDGE=`${SED-sed} -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev`

killall dhcpcd{,-bin} 2>/dev/null

module="iwl3945"
IFACE="wlan0"
enc="off"
KEY="B453309546F8005A7A324C7046"
mode="managed"
NET="projekt mbs"
#ap="00:0F:CC:8A:3B:94"
ap="any"
#FREQ="2.412G"
FREQ="auto"
rts="off"
channel="1"
txpower="auto"

ifconfig "$IFACE" down
#rmmod "$module" 2>/dev/null
#modprobe "$module" 2>/dev/null

# BRIDGE setup
if test -n "$BRIDGE"; then
  ifconfig "$IFACE" 0 up

  # discard the BRIDGE if the wlan interface is not added to it
  if ! (brctl show | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q "^$BRIDGE.*$IFACE"); then
    ip link set "$BRIDGE" down
    unset BRIDGE
  fi
fi


ifconfig "${BRIDGE:-$IFACE}" 0 up
iwlist "$IFACE" scanning essid "$NET"
iwconfig "$IFACE" enc "$KEY"
iwconfig "$IFACE" KEY restricted "$KEY"
iwconfig "$IFACE" mode "$mode"
iwconfig "$IFACE" essid "$NET"
iwconfig "$IFACE" ap "$ap"
iwconfig "$IFACE" rts "$rts"
iwconfig "$IFACE" FREQ "$FREQ"
#iwconfig "$IFACE" txpower "$txpower"
iwconfig "$IFACE" channel "$channel"
dhcpcd -dd -p -R "${BRIDGE:-$IFACE}"

if test -e /etc/service/dnscache; then
  sv restart dnscache
fi
