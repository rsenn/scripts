#!/bin/bash
EXTS="rar zip 7z tar.gz tar.xz tar.bz2 tgz txz tbz2 exe msi deb rpm iso daa dmg run pkg app bin iso daa nrg dmg exe sh tar.Z tar.gz zip"
EXTS="$EXTS 7z app bin daa deb dmg exe iso msi nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"

while :; do
  case "$1" in
    -c) COMPLETE=true; shift ;;
  *) break ;;
esac
done

[ "$COMPLETE" != true ] && TRAIL="[^/]*"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))${TRAIL}\$"  "$@"
