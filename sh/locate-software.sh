#!/bin/bash

. require.sh

require util

locate_videos()
{
    (IFS="
"; EXTS="setup*.exe install*.exe .msi .msu .cab .vbox-extpack .apk"

EXTS="$EXTS rar zip 7z tar.gz tar.xz tar.bz2 tgz txz tbz2 deb rpm iso daa dmg run pkg app"
EXTS="$EXTS 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"

 
 locate -i -r '.*' |grep -iE "($(IFS='| '; set -- $(echo "$EXTS" |${SED-sed} "s,\*,\[^/]*,g ; s/\./\\\\./g"); echo "$*"))\$"
 )
}

locate_videos "$@"
