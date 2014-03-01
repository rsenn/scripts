#!/bin/bash

locate_archives()
{
    (IFS="
 "; EXTS="7z rar tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_archives "$@"
