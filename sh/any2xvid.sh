#!/bin/bash

. require.sh

require info
require util

unset DIR FILESIZE

while :; do
    case "$1" in
   -b) VBR="$2"; shift 2 ;;
   -d) DIR="$2"; shift 2 ;;
   -s) FILESIZE="$2"; shift 2 ;;
  -a) A="$2"; shift 2 ;;
  -c) A="${A:+-vf crop=$2}" shift 2 ;;
     *) break ;;

    esac
done

case $FILESIZE in
    *[Mm]) FILESIZE=$(( ${FILESIZE%[Mm]} * 1048576)) ;;
    *[Kk]) FILESIZE=$(( ${FILESIZE%[Kk]} * 1024)) ;;
esac


type avconv 2>/dev/null >/dev/null && FFMPEG=avconv
: ${FFMPEG=ffmpeg}

IFS="
 "

var_dump()
{
  (
 SQ="'"
 BS="\\"
  CMD='echo';for N; do
    CMD="${CMD:+$CMD }\"$N='\${$N//\$SQ/\$BS\$SQ}'\""
   done
   eval   "$CMD")
}

minfo()
{
    mediainfo "$@" 2>&1 |${SED-sed} -u 's,\s*:,:, ; s, pixels$,, ; s,: *\([0-9]\+\) \([0-9]\+\),: \1\2,g' 
}

bce()
{
    (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | ${SED-sed} -u '/\./ s,\.\?0*$,,'
}

bci()
{
    (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | ${SED-sed} -u 's,\.[0-9]\+$,,'
}

duration()
{
    (for ARG; do minfo "$ARG" | info_get Duration| head -n1 ; done | ${SED-sed} 's,\([0-9]\+\)h,(\1 * 3600\)+, ; s,\([0-9]\+\)mn,(\1 * 60)+, ; s,\([0-9]\+\)s,\1+, ; s,+$,,' | bc -l)

}

is16to9()
{
    (R=`bci "( $1 / $2 ) * 3" `
    [ "$R" -gt  4 ])
}

size2ratio()
{
    (W=${1%%x*}
    H=${1#*x}

    R=`bci "($W / $H) * 100"`
    case "$R" in
  17?) echo 177 ;;
     *) echo "$R" ;;
 esac
    )
}

#ASPECT="4:3"
#SIZE="320x240"
: ${VBR:=$((800 * 1024))}

ABR=96000
AR=44100

case "$VBR" in
  *[Kk]) VBR=$((${VBR%[Kk]} * 1024)) ;;
esac

var_dump VBR

unset RESOLUTIONS
#pushv RESOLUTIONS 720x576
#pushv RESOLUTIONS 720x480
#pushv RESOLUTIONS 720x405
pushv RESOLUTIONS 640x480
pushv RESOLUTIONS 640x360
pushv RESOLUTIONS 512x288
pushv RESOLUTIONS 352x288

for ARG; do
    OUTPUT="${ARG%.*}.xvid.avi"
    if [ "$DIR" ]; then
  OUTPUT="$DIR"/`basename "$OUTPUT"`
fi
    WIDTH=`minfo "$ARG" |info_get Width`
    HEIGHT=`minfo "$ARG" |info_get Height`
    R=`size2ratio "${WIDTH}x${HEIGHT}"`
    unset SIZE

    is16to9 $WIDTH $HEIGHT && ASPECT="16:9" || ASPECT="4:3"

    while read RES; do
  R2=`size2ratio "$RES"`
  echo "Check ratio $(bce "$R2 / 100")" 1>&2
        
  if [ "$R" -eq "$R2" ]; then
      SIZE="$RES"
      break
  fi
    done <<<"$RESOLUTIONS"

    if [ "$SIZE" ]; then
   echo "Size is $SIZE" 1>&2
     else
   echo "WARNING: No appropriate size (ratio `bce "$R / 100"`) found!" 1>&2
     fi

     if [ "$FILESIZE" ]; then

   VBR=$(bci "$FILESIZE / $(duration "$ARG") * 8 - $ABR - 3000")

   echo "Calculated video bit rate to $VBR" 1>&2

     fi

    (set -x; "$FFMPEG" 2>&1 -y -i "$ARG" $A -r 29.97 -f avi -vcodec libxvid \
      ${ASPECT+-aspect "$ASPECT"} ${SIZE+-s "$SIZE"}  ${VBR:+-b $((VBR + ABR))} -acodec libmp3lame  \
   -ab "$ABR" -ar "$AR" -ac 2  "$OUTPUT" ) ||
        break
done

