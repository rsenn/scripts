#!/bin/bash

. require.sh

require util

locate_videos()
{
    (IFS="
"; EXTS="setup*.exe install*.exe .msi"

EXTS="$EXTS rar zip 7z tar.gz tar.xz tar.bz2 tgz txz tbz2 deb rpm iso daa dmg run pkg app"

 
 locate -i -r '.*' |grep -iE "($(IFS='| '; set -- $(echo "$EXTS" |sed "s,\*,\[^/]*,g ; s/\./\\\\./g"); echo "$*"))\$"
 )
}

locate_videos "$@"
