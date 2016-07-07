#!/bin/sh
TABLES="filter nat"
TARGET=ACCEPT

filter_CHAINS="INPUT FORWARD OUTPUT"
nat_CHAINS="PREROUTING POSTROUTING OUTPUT"

for TABLE in $TABLES; do
  (set -x; iptables -t "$TABLE" --flush)

  eval "CHAINS=\"\$${TABLE}_CHAINS\""

  for CHAIN in $CHAINS; do
    (set -x; iptables -t "$TABLE" -P "$CHAIN" "$TARGET")
  done
done
