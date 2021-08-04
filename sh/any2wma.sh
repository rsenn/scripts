#!/bin/bash

BITRATE=96
SAMPLERATE=44100
CHANNELS=2
ACODEC="wmav2"
#FMT="wma"

for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.wma"
  OUTPUT="$BASE.wma"

  WAV="${BASE}-$$.wav"

        trap '[ "$WAV" != "$ARG" ] && rm -f "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
	    (set -x; ${FFMPEG-ffmpeg} -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "${BITRATE}k"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

  )
done
