#!/bin/sh
NL="
"

BRIDGE=`${SED-sed} -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev`

killall dhcpcd{,-bin} 2>/dev/null

IFACE="wlan0"
KEY="AABBCCDDEEFF11335577992244"
NET="tmwnet"

iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" essid "$NET"

# BRIDGE setup
if test -n "$BRIDGE"; then
  ifconfig "$IFACE" 0 up

  # discard the BRIDGE if the wlan interface is not added to it
  if ! (brctl show | ${GREP-grep -a --line-buffered --color=auto} -q "^$BRIDGE.*$IFACE"); then
    ip link set "$BRIDGE" down
    unset BRIDGE
  fi
fi



dhcpcd -dd -p -R "${BRIDGE:-$IFACE}"

if test -e /etc/service/dnscache; then
  sv restart dnscache
fi
