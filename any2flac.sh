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

  if type mpg123 2>/dev/null >/dev/null; then
  (set -x; mpg123 -w "$WAV" "$ARG") 
elif type mplayer  2>/dev/null >/dev/null; then

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG")
   fi &&
  if type flac 2>/dev/null >/dev/null; then
				(set -x; flac  ${SAMPLERATE:+--sample-rate="$SAMPLERATE"} ${CHANNELS:+--channels="$CHANNELS"} -o "$OUTPUT" "$WAV")
   elif type ffmpeg  2>/dev/null >/dev/null; then
	    (set -x; ffmpeg -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "${BITRATE}k"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")
   fi
  )
done
