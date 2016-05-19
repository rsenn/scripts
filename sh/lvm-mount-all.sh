#!/bin/sh
lvs | awk '{ print $1" "$2 }' | ${SED-sed} 1d | 
while read LV VG; do 
  lvchange -ay "/dev/$VG/$LV"
  mkdir -p "/mnt/$VG/$LV"
  mount "/dev/$VG/$LV" "/mnt/$VG/$LV"
done                  
