#!/bin/sh
CONFIG="$HOME/wpa_supplicant.conf"

if [ "$1" = "-l" ]; then
  iwlist wlan0 scanning|grep ESSID|sed 's,:",=", ;s,^\s*,, ; s,ESSID="\(.*\)",\1,'           
  exit $?
fi

if [ $# -gt 1 ]; then
  CONFIG=`mktemp -p /tmp/ wpa_supplicant.conf-XXXXXX` 
  trap 'rm -f "$CONFIG"' EXIT
  wpa_passphrase "$1" "$2" >"$CONFIG"||exit $?
fi
set -x
IF=wlan0
killall wpa_supplicant dhcpcd dhclient pump
sleep 1
killall -9 wpa_supplicant dhcpcd dhclient pump
ifconfig $IF down
ifconfig $IF 0 up
wpa_supplicant -i ${IF}   -c "$CONFIG" 
##dhcpcd ${IF}
