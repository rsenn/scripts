#!/bin/sh

arp-scan "$@" | sed -n -u \
  -e "s/^\([.0-9]\+\)\s\+\([:0-9A-Fa-f]\+\)\s\+\(.*\)\$/\1\t\2\t\3/p"
