#!/bin/bash

locate_videos()
{
    (IFS="
 "; EXTS="avi flv wmv mpg mpeg mp4 mkv mov 3gp"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_videos "$@"
