#!/bin/bash
EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf xpm xwd"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
