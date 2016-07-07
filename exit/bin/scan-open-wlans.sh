#!/bin/sh
NL="
"
IF=wlan0

if [ "`id -u`" != 0 ]; then
  echo "Must be root!" 1>&2
  exit 1
fi

iwlist "$IF" scanning | ${GREP-grep
-a
--line-buffered
--color=auto} -i -B6 -A1 KEY:off
