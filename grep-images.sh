#!/bin/sh

set -- bmp emf gif jpeg jpg png pnm ppm psd tga tif tiff wmf xcf
set -- "$@" dxf dwg svg svgz 
set -- "$@" ps eps 
set -- "$@" ico cur 
set -- "$@" art avs cut dcm dib dpx fax fpx jnx jp2 mac mat mpc mtv otb pcd pcl pcx pdb pix ps2 ps3 pwp rgb rla rle sct sfw sgi sun tim wpg xbm xpm xwd 

exec grep -iE "\\.($(IFS='|'; echo "$*"))\$"
