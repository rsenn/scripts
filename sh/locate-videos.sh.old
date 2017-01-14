#!/bin/bash

locate_videos()
{
    (IFS="
 "; EXTS="3gp avi f4v flv m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
 
  while :; do
    case "$1" in
      -c | --compl*) COMPLETE=true ; shift ;;
      *) break ;;
    esac
  done

  if [ "$COMPLETE" != true ]; then
    TRAILING="(\.!..|\.part|)"
  fi

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))${TRAILING}\$"
 )
}

locate_videos "$@"
