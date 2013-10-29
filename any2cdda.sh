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


in_path () 
{ 
    local dir IFS=:;
    for dir in $PATH;
    do
        ( cd "$dir" 2> /dev/null && set -- $1 && test -e "$1" ) && return 0;
    done;
    return 127
}


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

in_path mpg321 && MPG321="mpg321"
in_path sox && SOX="sox"
in_path mplayer && MPLAYER="mplayer"

ABR=128
AR=44100

for ARG; do

    CDDA="${ARG%.*}.cdda"
    if [ "$DIR" ]; then
	CDDA="$DIR"/`basename "$CDDA"`
fi

    (set -x; 
trap 'R=$?; rm -f "$CDDA"; exit $R' EXIT QUIT INT TERM

if [ "$SOX" ]; then
"$SOX" -S "$ARG" -t cdda --rate "$ABR" --bits 16 --channels 2 "$CDDA"
elif [ "$MPG321" ]; then
"$MPG321" --cdr "$CDDA" "$ARG"
fi && trap '' EXIT
#mplayer -really-quiet -noconsolecontrols -ao pcm:waveheader:file="$CDDA" -vo null "$ARG"  2>/dev/null
)
done

