#!/bin/bash
EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff
opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf
xpm xwd"


while :; do
  case "$1" in
    -c) COMPLETE=true; shift ;;
  *) break ;;
esac
done

[ "$COMPLETE" != true ] && TRAIL="[^/]*"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))${TRAIL}\$"  "$@"
