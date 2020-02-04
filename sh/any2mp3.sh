
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
   -x|--debug) DEBUG=true; shift ;;
   -P) NOPIPE=true; shift ;;
   -r) REMOVE=true; shift ;;
   -b) ABR="$2"; shift 2 ;;
   -d) DESTDIR="$2"; shift 2 ;;
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
  trap '[ "$WAV" != "$ARG" -a "$REMOVE" != false ] && rm -f "$WAV"' EXIT
  trap 'exit 3' INT TERM

    OUTPUT="${ARG%.*}.mp3"
    OUTPUT=${OUTPUT//[![:print:]]/""}
    if [ "$DESTDIR" ]; then
      OUTPUT="$DESTDIR"/`basename "$OUTPUT"`
    fi

    (#set -x; 
  trap 'R=$?; rm -vf "$WAV"; exit $R' EXIT QUIT INT TERM

  #(cd "$DIR"; mplayer -quiet -noconsolecontrols -benchmark -ao pcm:fast:file="${WAV##*/}" -vc null -vo null "${ARG##*/}"  2>/dev/null) &&
  #(mplayer -quiet -noconsolecontrols -benchmark -ao pcm:fast:file="${WAV}" -vc null -vo null "${ARG}"  2>/dev/null) &&
  DECODE=

  case "${ARG##*/}" in
	  *.wav) DECODE=; WAV="$ARG" ;;
	  *.669 | *.amf | *.amf | *.dsm | *.far | *.gdm | *.gt2 | *.it | *.imf | *.mod | *.med | *.mtm | *.okt | *.s3m | *.stm | *.stx | *.ult | *.umx | *.apun | *.xm | *.mod) 
		#mikmod -q -d 5  -p 1 -o 16s -i -hq -reverb 1 -fadeout  -norc -x "${ARG}" ; 	  WAV="music.wav"
		DECODE='xmp "$ARG" -d wav -o -'
		SONG="${ARG##*/}"
	  ;;
	  *)
	  DECODE='
	  
	  case "${ARG}" in
	    *.ogg) oggdec -o "$WAV" "$ARG" ;;
	    *.mp3) 
          mpg123 -w "$WAV" "$ARG" ||
          madplay --output="$WAV":wave -S -R 44100 "$ARG" || 
          false 
        ;;
	    *)   ffmpeg -v 0 -y -i "${ARG}" -acodec pcm_s16le -f wav -ac 2 -ar 44100 "$WAV" || mplayer -really-quiet -noconsolecontrols -ao pcm:waveheader:file="$WAV" -vo null "$ARG"
	    
	    esac  ' # ||


	  ;;
  esac

   (
  if [ "$ARG" = "$OUTPUT" ]; then
	REMOVE=false
  fi
  if [ "$ARG" = "$WAV" ]; then
	REMOVE=false
  fi

  set -e #; set -x

  if type shineenc >/dev/null 2>/dev/null; then
	ENCODE="shineenc  -b \"\$ABR\" \"\$WAV\" \"\$OUTPUT\" "
  else
	ENCODE="lame --alt-preset \"\$ABR\" --resample 44100 -m j -h - \"\$OUTPUT\" "
  fi
  #if [ "$NOPIPE" = true ]; then
	CMD="${DECODE:+${DECODE/ - / \"\$WAV\"} && }${ENCODE/ - / \"\$WAV\" }"
  #  else
  #CMD="$DECODE | $ENCODE"
  #fi

  [ "$DEBUG" = true ] && {
   O=
  set -- $CMD; for A; do 
	case "$A" in
	  *" "*|*\$*) eval O="\"$O '${A//'/\\'}'\"" ;;
	  *) eval O="\"$O $A\"" ;;
	esac
   done; echo "$O"
   }
   echo "CMD='$CMD'" 1>&2
  eval "(set -x; $CMD)"
  R=$?
  if [ "$R" = 0 -a "$ARG" != "$WAV" ]; then
	REMOVE=true
  fi
  [ -n "$SONG" ] && id3v2 --song "$SONG" "$OUTPUT"
  exit $R
  ) &&

  if [ "$REMOVE" = true ]; then rm -vf "$ARG"; fi) ||break
  ) || { R=$?; if [ "$R" = 3 ]; then exit $R; fi; }
done
