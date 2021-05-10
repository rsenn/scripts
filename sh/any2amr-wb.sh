#!/bin/bash

BITRATE=96
SAMPLERATE=16000
CHANNELS=1
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

        trap '[ "$WAV" != "$ARG" ] && rm -vf "$WAV"' EXIT QUIT INT TERM

  (set -x; mplayer  -really-quiet -noconsolecontrols -vo null -vc null ${SAMPLERATE+-af resample=$SAMPLERATE} -ao pcm:waveheader:file="$WAV" "$ARG") &&
					(set -x; #sox -S  "$WAV" -t awb "$OUTPUT" ||
                    sox -S "$WAV" -t amr-wb -c "$CHANNELS" -r "$SAMPLERATE" -C 4 "$OUTPUT" ||
                    ${FFMPEG-ffmpeg} -y -i "$WAV"  -acodec amr_wb  ${SRATE:+-ar "$SRATE"}  ${CHANNELS:+-ac "$CHANNELS"} "$OUTPUT")
  )
done
