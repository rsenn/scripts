#!/bin/bash

: ${BITRATE=96k}
#SAMPLERATE=44100
#CHANNELS=2
ACODEC="aac"


for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.m4a"
  OUTPUT="$BASE.m4a"

  WAV="${BASE}-$$.wav"

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM


  (
	
#	[ -n "$OUTDIR" ] && OUTPUT="$OUTDIR/$OUTPUT"
	
	set -x; mplayer -really-quiet -noconsolecontrols -vo null -vc null -ao pcm:waveheader:file="$WAV" "$ARG") &&
#					(set -x; faac  ${BITRATE:+-b "$BITRATE"}  -o "${OUTDIR:+$OUTDIR/}$OUTPUT" "$WAV")
    (set -x;  "${FFMPEG:-ffmpeg}" -strict -2 -y  -i "$WAV"  ${ACODEC:+-acodec "$ACODEC"} -ab "${BITRATE}" -strict experimental \
			${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "${OUTDIR:+$OUTDIR/}$OUTPUT")

  )
done
