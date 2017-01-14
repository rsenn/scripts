#!/bin/bash

locate_images()
{
    (IFS="
 "
   ANY=".*"
 while :; do
      case "$1" in
            -x | --debug) DEBUG=true; shift ;;
            -f | --filepart) ANY="[^/]*"; shift ;;
            *) break ;;
            esac
            done
    EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf xpm xwd"
 [ $# -le 0 ] && set -- ".*"
 for ARG; do ([ "$DEBUG" = true ] && set -x; locate -i -r "$ARG"); done |(
     
     set -- grep -iE "($(IFS='| '; echo "$*"))$ANY\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"; 
     [ "$DEBUG" = true ] && set -x
     "$@"
     
     )
  )
}

locate_images "$@"
