#!/bin/bash

locate_audio()
{
    (IFS="
 "; EXTS="aif aiff flac m4a m4b mp2 mp3 mpc ogg raw rm wav wma"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_audio "$@"
