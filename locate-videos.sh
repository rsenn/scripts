#!/bin/bash

locate_videos()
{
    (IFS="
 "; EXTS="avi flv wmv mpg mpeg mp4 mkv mov 3gp"
 
  while :; do
    case "$1" in
      -c | --compl*) COMPLETE=true ; shift ;;
      *) break ;;
    esac
  done

  if [ "$COMPLETE" != true ]; then
    TRAILING="(\.!..|\.part|)"
  fi

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))${TRAILING}\$"
 )
}

locate_videos "$@"
