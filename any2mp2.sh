#!/bin/bash

BITRATE=96
SAMPLERATE=44100
CHANNELS=2
ACODEC="mp2"

for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.mp2"
  OUTPUT="$BASE.mp2"

  WAV=`mktemp "${BASE}XXXXXX.wav"`

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
	    (set -x; twolame ${BITRATE+-b "${BITRATE}k"} ${SAMPLERATE:+-s "$SAMPLERATE"} ${CHANNELS:+-N "$CHANNELS"} "$WAV" "$OUTPUT")
	#    (set -x; ffmpeg -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "${BITRATE}k"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

  )
done
