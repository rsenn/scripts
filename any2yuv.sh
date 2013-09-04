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
ABR=128
AR=44100

for ARG; do

    YUV4MPEG="${ARG%.*}.yuv"
    if [ "$DIR" ]; then
	YUV4MPEG="$DIR"/`basename "$YUV4MPEG"`
fi

    (set -x; 
trap 'R=$?; rm -f "$YUV4MPEG"; exit $R' EXIT QUIT INT TERM
mplayer -noconsolecontrols -ao null -vc null -vo yuv4mpeg:file="$YUV4MPEG" "$ARG"  2>/dev/null)
done

