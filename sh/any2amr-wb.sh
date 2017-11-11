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
  OUTPUT="$BASE.amr"

  WAV="${BASE}-$$.wav"

        trap 'rm -vf "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
					(set -x; #sox -S  "$WAV" -t awb "$OUTPUT" ||
                    sox -S "$WAV" -t amr-wb -c 1 -r 16000 -C 4 "$OUTPUT" ||
                    ${FFMPEG-ffmpeg} -y -i "$WAV"  -acodec libopencore_amrwb  ${SRATE:+-ar "$SRATE"}  ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")
  )
done
