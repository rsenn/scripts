 #!/bin/bash
# To convert a ps file into png format
# Usage:
#            ps2png [psfile.ps]
# @ http://scriptdemo.blogspot.com

IFS="
"

if [ $# == 0 ]; then
   for psname in *.ps
   do
         if [ -e $psname ]; then
            pngname=`echo ${psname%%.*}`
            convert $psname ${pngname}.png
         else
            echo "${psname} does not exist!"
         fi
   done
else
   for psname in $*
   do
        if [ -e $psname ]; then
           pngname=`echo ${psname%%.*}`
           convert $psname ${pngname}.png
        else
           echo "${psname} does not exist!"
        fi
   done
fi
