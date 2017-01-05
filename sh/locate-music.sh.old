#!/bin/bash

locate_music()
{
    (IFS="
 "; EXTS="mp3 ogg flac mpc m4a m4b wma rm mp4"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_music "$@"
