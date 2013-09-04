#!/bin/bash

. require.sh

require info
require util

unset DIR FILESIZE

while :; do
    case "$1" in
	 -d) DIR="$2"; shift 2 ;;
	 -s) FILESIZE="$2"; shift 2 ;;
     *) break ;;

    esac
done

case $FILESIZE in
    *[Mm]) FILESIZE=$(( ${FILESIZE%[Mm]} * 1048576)) ;;
    *[Kk]) FILESIZE=$(( ${FILESIZE%[Kk]} * 1024)) ;;
esac


IFS="
 "

minfo()
{
    mediainfo "$@" 2>&1 |sed -u 's,\s*:,:, ; s, pixels$,, ; s,: *\([0-9]\+\) \([0-9]\+\),: \1\2,g' 
}

bce()
{
    (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | sed -u '/\./ s,\.\?0*$,,'
}

bci()
{
    (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | sed -u 's,\.[0-9]\+$,,'
}

duration()
{
    (for ARG; do minfo "$ARG" | info_get Duration| head -n1 ; done | sed 's,\([0-9]\+\)h,(\1 * 3600\)+, ; s,\([0-9]\+\)mn,(\1 * 60)+, ; s,\([0-9]\+\)s,\1+, ; s,+$,,' | bc -l)

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
VBR=$((1800 * 1024))
ABR=96
AR=44100
unset RESOLUTIONS
pushv RESOLUTIONS 720x576
pushv RESOLUTIONS 720x480
pushv RESOLUTIONS 720x405
#pushv RESOLUTIONS 704x576
#pushv RESOLUTIONS 352x576
#pushv RESOLUTIONS 704x480
pushv RESOLUTIONS 512x288
pushv RESOLUTIONS 352x480
pushv RESOLUTIONS 352x288
pushv RESOLUTIONS 352x240

for ARG; do
    OUTPUT="${ARG%.*}.dvd.mpg"
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

unset VBR ABR AR 

    (set -x; 
#ffmpeg -y -i "$ARG" -target pal-dvd ${ASPECT+-aspect "$ASPECT"} ${SIZE+-s "$SIZE"}  ${VBR+-b "$VBR"}  ${ABR:+-ab "$ABR"} ${AR:+-ar "$AR"} -ac 2  "$OUTPUT"
#mencoder -oac lavc -ovc lavc -of mpeg -mpegopts format=dvd:tsaf -vf ${SIZE:+scale=${SIZE%x*}:${SIZE#*x},}harddup ${AR:+-srate "$AR" -af lavcresample="$AR"} -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=15:vstrict=0:acodec=ac3${ABR:+abitrate="$ABR":}:aspect=16/9 -ofps 25 -o "$OUTPUT" "$ARG"


transcode --verbose 2   -i "$ARG" -y ffmpeg --export_prof dvd-pal --export_asr 3 -o "${OUTPUT%.*}.m2v" -D0 -s2 -m "${OUTPUT%.*}.ac3" -J modfps=clonetype=3 --export_fps 25 &&
 mplex -f8 -o "$OUTPUT" "${OUTPUT%.*}".{m2v,ac3}



) ||
	      break
done

