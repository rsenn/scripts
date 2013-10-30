#!/bin/bash

. require.sh

require info
require util

unset DIR FILESIZE

while :; do
    case "$1" in
   -p=* |--pcm=*) PCM="${1#*=}"; shift  ;;
 -p |--pcm) PCM="${2}"; shift  2 ;;
   -d) DIR="$2"; shift 2 ;;
   -s) FILESIZE="$2"; shift 2 ;;
   -r) SRATE="$2"; shift 2 ;;
#   -b) BITRATE="$2"; shift 2 ;;
   -c) CHANNELS="$2"; shift 2 ;;
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
ABR=128
AR=44100

for ARG; do

    WAV="${ARG%.*}.wav"
    if [ "$DIR" ]; then
  WAV="$DIR"/`basename "$WAV"`
fi

    (set -x; 
trap 'R=$?; rm -f "$WAV"; exit $R' EXIT QUIT INT TERM
#mplayer -really-quiet -noconsolecontrols -ao pcm:waveheader:file="$WAV" -vo null "$ARG"  2>/dev/null||
   ffmpeg -y -i "$ARG"  -acodec pcm_${PCM:-s16le} ${SRATE:+-ar "$SRATE"}  ${CHANNELS:+-ac "$CHANNELS"} "$WAV"   || exit $?
trap '' EXIT QUIT INT TERM

  ) || break
done #2>&1|sed -u '1d;2d;3d;/^\s\+lib/d'

