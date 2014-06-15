#!/bin/bash

. require.sh

require info
require util

unset DIR FILESIZE

REMOVE=false

while :; do
    case "$1" in
   -r) REMOVE=true; shift ;;
   -b) ABR="$2"; shift 2 ;;
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
: ${ABR=128}
: ${AR=44100}

for ARG; do
#    WAV="${ARG%.*}.wav"
    WAV=`mktemp "${0##*/}XXXXXX.wav"`

    OUTPUT="${ARG%.*}.mp3"
    if [ "$DIR" ]; then
  OUTPUT="$DIR"/`basename "$OUTPUT"`
fi

    (set -x; 
trap 'R=$?; rm -vf "$WAV"; exit $R' EXIT QUIT INT TERM
mplayer -quiet -noconsolecontrols -benchmark -ao pcm:fast:file="$WAV" -vc null -vo null "$ARG"  2>/dev/null &&
lame --alt-preset "$ABR" -h "$WAV" "$OUTPUT" &&
if $REMOVE; then rm -vf "$ARG"; fi) ||break
done

