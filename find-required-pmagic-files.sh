#!/bin/sh
MYBASE=`basename "$0" .sh`
MYDIR=`dirname "$0"`

while :; do
case "$1" in
  -i | --invert*) INVERT=true; shift ;;
  *) break ;;
  esac
  done
  
[ "$INVERT" = true ] && NOT="-v"

cd "$MYDIR"

EXPR='(^bzImage|initramfs[^/]*$|initrd[^/]*$|initrd[^.]*\.img|pmodules/[^/]*\.SQFS$|pmodules/[^/]*\.t.z$|pmodules/z[^/]*\.xz$)'
(
  find . -type f
) |
sed -u 's,^\./,,' | grep -i -E $NOT "$EXPR" |
sort -u