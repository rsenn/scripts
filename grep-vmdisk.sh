#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"
cr=""
exec grep -i -E "\\.($(IFS='| '; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}${cr}?\$"  "$@"
