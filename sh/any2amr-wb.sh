#!/bin/bash

BITRATE=96
SAMPLERATE=44100
CHANNELS=2
ACODEC="amr-wb"
#FMT="amr-wb"

for ARG; do
  (
  BASE=`basename "$ARG"`
  BASE=${BASE%.*}

  DIR=`dirname "$ARG"`

        cd "$DIR"

  #OUTPUT="${ARG%.*}.amr-wb"
  OUTPUT="$BASE.amr-wb"

  WAV="${BASE}-$$.wav"

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
					(set -x; sox -S  "$WAV" -t amr-wb "$OUTPUT")
			#		(set -x; amrwb-encoder -dtx 7 "$WAV" "$OUTPUT")
	    #(set -x; ${FFMPEG-ffmpeg} -y -strict -2 -i "$WAV" ${FMT+-f "$FMT"} ${ACODEC:+-acodec "$ACODEC"}   ${BITRATE+-ab "${BITRATE}k"} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")

  )
done
