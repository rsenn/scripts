
#!/bin/bash

MYNAME=`basename "${0%.sh}"`
MYDIR=`dirname "$0"`

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
: ${ABR=128}
: ${AR=44100}

for ARG; do
(
#    WAV="${ARG%.*}.wav"
    DIR=`dirname "$ARG"`
    WAV="${MYNAME}-$$.wav"
trap 'rm -f "$WAV"' EXIT
trap 'exit 3' INT TERM

    OUTPUT="${ARG%.*}.mp3"
    if [ "$DIR" ]; then
      OUTPUT="$DIR"/`basename "$OUTPUT"`
    fi

    (set -x; 
trap 'R=$?; rm -vf "$WAV"; exit $R' EXIT QUIT INT TERM
#(cd "$DIR"; mplayer -quiet -noconsolecontrols -benchmark -ao pcm:fast:file="${WAV##*/}" -vc null -vo null "${ARG##*/}"  2>/dev/null) &&
#(mplayer -quiet -noconsolecontrols -benchmark -ao pcm:fast:file="${WAV}" -vc null -vo null "${ARG}"  2>/dev/null) &&

case "${ARG##*/}" in
	*.wav) WAV="$ARG" ;;
	*.669 | *.amf | *.amf | *.dsm | *.far | *.gdm | *.gt2 | *.it | *.imf | *.mod | *.med | *.mtm | *.okt | *.s3m | *.stm | *.stx | *.ult | *.umx | *.apun | *.xm | *.mod) 
	  #mikmod -q -d 5  -p 1 -o 16s -i -hq -reverb 1 -fadeout  -norc -x "${ARG}" ; 	  WAV="music.wav"
	  xmp "$ARG" -d wav -o "$WAV" 
	  SONG="${ARG##*/}"
	;;
	*)
	(${FFMPEG:-ffmpeg} -v 0 -y -i "${ARG}" -acodec pcm_s16le -f wav -ac 2 -ar 44100 "$WAV") 
	;;
esac && (set -e; set -x
shineenc  -b "$ABR" -j "$WAV" "$OUTPUT"  ||
lame --alt-preset "$ABR" --resample 44100 -m j -h "$WAV" "$OUTPUT" 
[ -n "$SONG" ] && id3v2 --song "$SONG" "$OUTPUT"
) &&

if $REMOVE; then rm -vf "$ARG"; fi) ||break
) || { R=$?; if [ "$R" = 3 ]; then exit $R; fi; }
done

