#!/bin/bash

BITRATE="96k"
SAMPLERATE=44100
CHANNELS=2
#ACODEC="aac"

for ARG; do
	(
	BASE=${ARG##*/}
	BASE=${BASE%.*}

	DIR=${ARG%/*}

        cd "$DIR"

	#OUTPUT="${ARG%.*}.m4a"
	OUTPUT="$BASE.m4a"

	WAV=`mktemp "${BASE}XXXXXX.wav"`

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM

	(set -x; mplayer -really-quiet -noconsolecontrols -vo null -vc null -ao pcm:waveheader:file="$WAV" "$ARG") &&
		(set -x; ffmpeg -y -i "$WAV" ${ACODEC:+-acodec "$ACODEC"}  -ab "$BITRATE" ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

	)
done
