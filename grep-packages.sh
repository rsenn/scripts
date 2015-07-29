#!/bin/bash
EXTS="txz tgz rpm deb"

cr=""
exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*${cr}?\$"  "$@"
