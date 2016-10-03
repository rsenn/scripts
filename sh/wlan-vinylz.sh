#!/bin/sh

IFACE="wlan0"
KEY="7a83069a9916cab2d949a12cf8"
NET="vinylz"

killall dhclient

iwconfig "$IFACE" KEY "$KEY"
iwconfig "$IFACE" essid "$NET"
dhclient "$IFACE"
