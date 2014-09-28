#!/bin/sh

IFS=:
I=0

while read color code; do 
  printf "%-20s\t%-20s\t%03d\n" "$color ($code)" "$code: $color" "$I"

  I=`expr $I + 10`
done <colors
