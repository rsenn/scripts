#!/bin/bash

. require.sh

require util

locate_videos()
{
    (IFS="
"; EXTS="setup*.exe install*.exe .msi"

 
 locate -i -r '.*' |grep -iE "($(IFS='| '; set -- $(echo "$EXTS" |sed "s,\*,\[^/]*,g ; s/\./\\\\./g"); echo "$*"))\$"
 )
}

locate_videos "$@"
