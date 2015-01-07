#!/bin/sh

IFACE="wlan0"
KEY="533435445"
NET="Hotel-Flora"

{ iwconfig "$IFACE" KEY "$KEY" &&
  iwconfig "$IFACE" essid "$NET" &&
  dhclient "$IFACE"
} || {
  iwconfig "$IFACE" KEY off
}
