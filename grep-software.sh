#!/bin/bash
EXTS="rar zip 7z tar.gz tar.xz tar.bz2 tgz txz tbz2 exe msi deb rpm"

exec grep --binary-files=text -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
