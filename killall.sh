#!/bin/bash
IFS="
"
while :; do
	case "$1" in
		 -*) OPTS="${OPTS+$OPTS
}$1"; shift ;;
	 *) break ;;
	esac
done

IFS="|$IFS"

PIDS=`ps -aW | grep -iE "($*)" | sed -n "s,^[^0-9]*\([0-9]\+\).*,\1,p"`

if [ -z "$PIDS" ]; then
  echo "No matching process ($@)" 1>&2
  exit 2
fi
set -x
exec kill.exe $OPTS -f $PIDS



