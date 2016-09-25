#!/bin/bash

locate_music()
{
    (IFS="
 "; EXTS="mp3 ogg flac mpc m4a m4b wma rm mp4"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_music "$@"
