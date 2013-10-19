#!/bin/sh
for FILE; do 
  BASE=`basename "$FILE"` DIR=`dirname "$FILE"`
  LOWER=`echo "$BASE" | tr "[:upper:]" "[:lower:]"`
  
  if [ "$LOWER" != "$BASE" ]; then
    mv -v "$DIR/$BASE" "$DIR/$LOWER" || break
  fi
done
