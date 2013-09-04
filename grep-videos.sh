#!/bin/bash
EXTS="mkv 3gp avi flv mp4 wmv mov mpg mpeg"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
