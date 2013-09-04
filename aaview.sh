#!/bin/sh
unset DISPLAY
TMP=$(tempfile -s .pnm)
rm -f "$TMP"
trap 'rm -f "$TMP"' EXIT
convert "$1" "$TMP"
aview -kbddriver stdin -driver stdout "$TMP"
