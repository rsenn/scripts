#!/bin/bash

#ABITRATE="96k"
SAMPLERATE=32000
CHANNELS=2
#VCODEC=h263
VCODEC=h263p
SIZE=172x144

#ACODEC="aac"
ACODEC="amrwb"

for ARG; do
	(
	BASE=${ARG##*/}
	BASE=${BASE%.*}

	DIR=${ARG%/*}

        cd "$DIR"

	#OUTPUT="${ARG%.*}.3gp"
	OUTPUT="$BASE.3gp"

	TMP=`mktemp "${BASE}XXXXXX.tmp"`

        trap 'rm -vf "$TMP"' EXIT QUIT INT TERM

#	(set -x; mplayer -really-quiet -noconsolecontrols -vo null -vc null -ao pcm:waveheader:file="$TMP" "$ARG") &&
		(set -x; ffmpeg -y -i "$TMP" \
                        ${SIZE:+-s "$SIZE"} \
			${VCODEC:+-vcodec "$VCODEC"} ${VBITRATE:+-b:v "$VBITRATE"} \
			${ACODEC:+-acodec "$ACODEC"} ${ABITRATE:+-b:a "$ABITRATE"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} \
		   "$OUTPUT")

	)
done
