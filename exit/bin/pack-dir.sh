#!/bin/sh
IFS="
"
ARGS="$*"

for DIR in $ARGS; do
	(NAME=`cd "$DIR" &&  echo "${PWD##*/}"`
	 PARENT=`cd "$DIR" && cd .. && echo "${PWD}"`

	 ARCHIVE="$NAME-`date +%Y%m%d`.zip"

	 cd "$DIR"
	 (set -x
#	 zip -3 -r "$PARENT/$ARCHIVE"  .
7z a -mx=3 "$PARENT/$ARCHIVE" .)
	 echo "Created '$PARENT/$ARCHIVE' ... " 1>&2
	 )

 done



