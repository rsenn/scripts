#!/bin/bash
EXTS="txz tgz rpm deb"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
