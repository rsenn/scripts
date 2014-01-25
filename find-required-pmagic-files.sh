#!/bin/bash


MYBASE=`basename "$0" .sh`
MYDIR=`dirname "$0"`

while :; do
case "$1" in
  -i | --invert*) INVERT=true; shift ;;
  -P | --no*pkgs*) NO_PKGS=true; shift ;;
  *) break ;;
  esac
  done
  
[ "$INVERT" = true ] && NOT="-v"

cd "$MYDIR"

[ "$NO_PKGS" != true ]  && PKG_EXPR="pmodules/[^/]*\.t.z\$|pmodules/z[^/]*\.xz\$"
EXPR="(^bzImage|initramfs[^/]*\$|initrd[^/]*\$|initrd[^.]*\.img|pmodules/[^/]*\.SQFS\${PKG_EXPR:+|$PKG_EXPR})"

(
  find . -type f
) |
sed -u 's,^\./,,' | grep -i -E $NOT "$EXPR" |
sort -u
