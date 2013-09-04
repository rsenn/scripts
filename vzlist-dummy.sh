#!/bin/sh
VE_IDS=`sed </proc/user_beancounters -n "s/^\s*\([0-9]\+\):.*/\1/p"`

printf "      VEID      NPROC STATUS  IP_ADDR         HOSTNAME\n"
for VEID in $VE_IDS; do
  printf "     %5d          - running -               %s\n" $VEID $HOSTNAME
done

