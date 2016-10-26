#!/bin/bash

locate_audio()
{
    (IFS="
 "; EXTS="aif aiff flac m4a m4b mp2 mp3 mpc ogg raw rm wav wma"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_audio "$@"
