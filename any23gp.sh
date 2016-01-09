#!/bin/bash

(
VBITRATE=409600
ABITRATE=96000
#SAMPLERATE=48000
#CHANNELS=2
VCODEC=h263
#VCODEC=h263p
SIZE=352x288

ACODEC="aac"
# ACODEC="amrwb"
#ACODEC="libmp3lame"
#ACODEC=aac
#ACODEC=ac3
#ACODEC=ac3_fixed
#ACODEC=alac
#ACODEC=dca
#ACODEC=eac3
#ACODEC=flac
#ACODEC=g722
#ACODEC=g723_1
#ACODEC=g726
#ACODEC=libmp3lame
#ACODEC=libvorbis
#ACODEC=nellymoser
#ACODEC=pcm_alaw
#ACODEC=pcm_f32be
#ACODEC=pcm_f32le
#ACODEC=pcm_f64be
#ACODEC=pcm_f64le
#ACODEC=pcm_mulaw
#ACODEC=pcm_s16be
#ACODEC=pcm_s16le
#ACODEC=pcm_s24be
#ACODEC=pcm_s24daud
#ACODEC=pcm_s24le
#ACODEC=pcm_s32be
#ACODEC=pcm_s32le
#ACODEC=pcm_s8
#ACODEC=pcm_u16be
#ACODEC=pcm_u16le
#ACODEC=pcm_u24be
#ACODEC=pcm_u24le
#ACODEC=pcm_u32be
#ACODEC=pcm_u32le
#ACODEC=pcm_u8
#ACODEC=real_144
#ACODEC=roq_dpcm
#ACODEC=sonic
#ACODEC=sonicls
c#ACODEC=vorbis
#ACODEC=wmav1
#ACODEC=wmav2

for ARG; do
  (
  BASE=${ARG##*/}
  BASENAME=${BASE%.*}

  DIR=` dirname "$ARG"` 

        cd "$DIR"

  #OUTPUT="${ARG%.*}.3gp"
  OUTPUT="$BASENAME.3gp"

#  TMP=`mktemp "${BASE}XXXXXX.tmp"`

        trap 'rm -vf "$TMP"' EXIT QUIT INT TERM

#  (set -x; mplayer -really-quiet -noconsolecontrols -vo null -vc null -ao pcm:waveheader:file="$TMP" "$ARG") &&
    (set -x; ${FFMPEG-ffmpeg} -y -i "$BASE" \
                        ${SIZE:+-s "$SIZE"} \
												${VCODEC:+-vcodec "$VCODEC"} ${VBITRATE:+-b:v $((VBITRATE))} \
	${ACODEC:+-acodec "$ACODEC"} -strict -2 ${ABITRATE:+-b:a $((ABITRATE))} ${SAMPLERATE:+-ar "$SAMPLERATE"} ${CHANNELS:+-ac "$CHANNELS"} \
       "$OUTPUT")

  )
done
)
