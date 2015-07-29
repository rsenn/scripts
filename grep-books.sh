#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="pdf epub mobi azw3 djv djvu"
cr=""
exec grep -i -E "\\.($(IFS='| '; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}${cr}?\$"  "$@"
