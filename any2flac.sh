#!/bin/bash

#BITRATE=96
SAMPLERATE=44100
CHANNELS=2
ACODEC="flac"
FMT="flac"
for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.flac"
  OUTPUT="$BASE.flac"

  WAV=`mktemp "${BASE}XXXXXX.wav"`

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM
rm -f "$OUTPUT"
  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
					(set -x; flac  ${SAMPLERATE:+--sample-rate="$SAMPLERATE"} ${CHANNELS:+--channels="$CHANNELS"} -o "$OUTPUT" "$WAV")
	    #"(set -x; ffmpeg -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "${BITRATE}k"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

  )
done
