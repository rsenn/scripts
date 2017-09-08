#!/bin/bash

unset DEV MNT
DEV=$1
MNT=$2
shift 2
while :; do
  [ $# = 0 ] && break
  case "$1" in
	  -o) OPTS="${OPTS:+$OPTS,}$2"; shift 2; continue ;;
	  -t) TYPE="$2"; shift 2; continue ;;
	  *) break ;;
  esac
done
set -x


OPTS=${OPTS//'\040'/' '}
OPTS=${OPTS//'\x20'/' '}
#OPTS=`echo "$OPTS" | sed 's,\\040, ,g ; s,\\x20, ,g'`
echo "OPTS='$OPTS'" 1>&2

exec afuse -o "$OPTS" "$MNT"

