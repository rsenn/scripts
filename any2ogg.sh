#!/bin/bash

BITRATE=96
SAMPLERATE=44100
CHANNELS=2
ACODEC="vorbis"
FMT="ogg"

for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.ogg"
  OUTPUT="$BASE.ogg"

  WAV=`mktemp "${BASE}XXXXXX.wav"`

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer -really-quiet -noconsolecontrols -vo null -vc null -ao pcm:waveheader:file="$WAV" "$ARG") &&
	#				(set -x; oggenc  ${BITRATE:+-b "$BITRATE"}  -o "$OUTPUT" "$WAV") 
	    (set -x; ffmpeg -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "$BITRATE"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

  )
done
