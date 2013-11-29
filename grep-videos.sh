#!/bin/bash
EXTS="mkv 3gp avi flv mp4 wmv mov mpg mpeg"

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
