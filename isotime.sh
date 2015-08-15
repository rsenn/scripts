#!/bin/sh

FMT="%Y%m%d-%H%M"

while :; do
  case "$1" in
    --ref*=*) DFILE="${1#*=}"; shift ;;
    -r | --ref*) DFILE="$2"; shift 2 ;;
    *) break ;;
  esac
done

if [ -e "$DFILE" ]; then
  UT=$(ls -n -l -d --time-style="+%s" "$DFILE" | awk '{ print $6 }')
fi
exec date ${UT:+--date="@${UT}"} +"$FMT" 
