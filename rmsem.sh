#!/bin/sh
# remove all semaphores
ipcs | awk '{ print $2 }' | sed -n  '/^semid$/ { n; :lp; /^$/q; p; n; b lp; }' | while read semid; do
  ipcrm -s "$semid"
done

