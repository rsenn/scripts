#!/bin/bash
EXTS="3gp avi f4v flv m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"

while :; do
        case "$1" in
                -c | --compl*) COMPLETE=true ; shift ;;
        *) break ;;
esac
done


if [ "$COMPLETE" != true ]; then
  TRAILING="[^/]*"
fi

EXPR="\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))${TRAILING}\$" 

exec grep -iE "$EXPR" \
        "$@"
