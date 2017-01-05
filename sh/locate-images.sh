#!/bin/bash

locate_images()
{
    (IFS="
 "; while :; do
      case "$1" in
            -x | --debug) DEBUG=true; shift ;;
            *) break ;;
            esac
            done
    EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf xpm xwd"
 [ $# -le 0 ] && set -- ".*"
 for ARG; do ([ "$DEBUG" = true ] && set -x; locate -i -r "$ARG"); done |(
     [ "$DEBUG" = true ] && set -x
     
     grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
     
     )
  )
}

locate_images "$@"
