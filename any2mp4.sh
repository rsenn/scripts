#!/bin/bash

. require.sh

require info
require util
require fs

unset DIR FILESIZE

while :; do
    case "$1" in
   -d) DIR="$2"; shift 2 ;;
   -s) FILESIZE="$2"; shift 2 ;;
   -r) REMOVE=true; shift ;;
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
VBR=$((1538 * 1024))
ABR=96
AR=48000
unset RESOLUTIONS
pushv RESOLUTIONS 720x576
pushv RESOLUTIONS 720x480
pushv RESOLUTIONS 640x360
#pushv RESOLUTIONS 720x405
#pushv RESOLUTIONS 704x576
#pushv RESOLUTIONS 352x576
#pushv RESOLUTIONS 704x480
pushv RESOLUTIONS 512x288
pushv RESOLUTIONS 352x480
pushv RESOLUTIONS 352x288
pushv RESOLUTIONS 352x240

for ARG; do
    OUTPUT="${ARG%.*}.x264.mp4"
    if [ "$DIR" ]; then
  OUTPUT="$DIR"/`basename "$OUTPUT"`
fi
    WIDTH=`minfo "$ARG" |info_get Width`
    HEIGHT=`minfo "$ARG" |info_get Height`
    R=`size2ratio "${WIDTH}x${HEIGHT}"`

    if [ "$WIDTH" -ge 1024 ]; then

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
    else
      SIZE="${WIDTH}x${HEIGHT}"
    fi    
    

    : ${FILESIZE:=$(fs_size "$ARG")}


     if [ "$FILESIZE" ]; then

   VBR=$(bci "$FILESIZE / $(duration "$ARG") * 8 - $ABR - 3000")

   echo "Calculated video bit rate to $VBR" 1>&2

     fi

#unset VBR ABR AR 

    (set -x; 
    MAXRATE=$((VBR -  (ABR * 1000) ))
    #FLAGS2="+brdo+dct8x8+bpyramid"
    #ME=umh
  VCODEC_OPTS="-level 41 -crf 20 -bufsize 20000k ${MAXRATE:+-maxrate $MAXRATE} -g 250 -r 20 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 ${FLAGS2:+-flags2 "$FLAGS2"} ${ME:+-me "$ME"} -subq 7 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -rc_eq 'blurCplx^(1-qComp)' -bf 16 -b_strategy 1 -bidir_refine 1 -refs 6 -deblockalpha 0 -deblockbeta 0"
  VCODEC_OPTS="-level 41 -crf 20 -bufsize 20000k ${MAXRATE:+-maxrate $MAXRATE} -g 250 -r 20 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 ${FLAGS2:+-flags2 "$FLAGS2"} ${ME:+-me "$ME"} -subq 7 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -rc_eq 'blurCplx^(1-qComp)' -bf 16 -b_strategy 1 -bidir_refine 1 -refs 6" 

( ${FFMPEG-ffmpeg} -y -threads 2  \
  -i "$ARG" \
  -acodec libfaac ${AR:+-ar "$AR"} -ab "$ABR"k \
  ${SIZE:+-s "$SIZE"}   \
  -b "$VBR" -vcodec libx264 $VCODEC_OPTS \
  "$OUTPUT" 2>&1 
) #| ${SED-sed} -u -e '1d; 2d; 3d; 4d; 5d; 6d; 7d; 8d; 9d; 10d; 11d'

exit 
  #X264OPTS="level_idc=12:bitrate=$((VBR )):bframes=16:subq=7:partitions=all:8x8dct:me=esa:me_range=23:frameref=6:trellis=1:b_pyramid:weight_b:mixed_refs:threads=0:qcomp=0.6:keyint=250:min-keyint=25:direct=temporal"
  X264OPTS="nocabac:level_idc=30:bframes=0:global_header:threads=auto:subq=5:frameref=6:partitions=all:trellis=1:chroma_me:me=umh:bitrate=$((VBR  / 1024 ))"
        #AOPTS="-oac lavc -lavcopts o=acodec=libfaac,absf=aac_adtstoasc -srate 48000 -af channels=2"
        AOPTS="-oac faac -faacopts mpeg=4:object=2:raw:br=$ABR"
mencoder ${ASPECT+-aspect "$ASPECT"} -vf scale="${SIZE%%x*}:${SIZE#*x}",harddup -ovc x264 -x264encopts "$X264OPTS" \
  $AOPTS \
-ofps 25 -noskip -of lavf -ofps 25 -lavfopts format=mp4 -o "$OUTPUT" "$ARG" -mf fps=25 && if ${REMOVE:-false} && test -s "$OUTPUT"; then
   rm -vf "$ARG"
  fi



) ||
        break
done

