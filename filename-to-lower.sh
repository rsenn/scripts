#!/bin/bash

for FILE; do

[ -e "$FILE" ] || continue

  BASE=`basename "$FILE"`
  DIR=`dirname "$FILE"`

  LOWER=`echo "$BASE" | tr "[:upper:]" "[:lower:]"`

  TMP="$LOWER".tmpXXXXXX

  if [ "$LOWER" != "$BASE" ]; then
   (cd "$DIR"
     TMPFILE="$BASE.tmp$RANDOM"
     trap 'rm -f "$TMPFILE"' EXIT
     #rm -f "$TMPFILE"

    
    mv -v -f "$BASE" "$TMPFILE"
    mv -v -f "$TMPFILE" "$LOWER"

   )
  fi

done
