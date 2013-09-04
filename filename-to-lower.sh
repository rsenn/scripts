#!/bin/sh

for FILE; do
  BASE=`basename "$FILE"`
  DIR=`dirname "$FILE"`

  LOWER=`echo "$BASE" | tr [:{upper,lower}:]`

  if [ "$LOWER" != "$BASE" ]; then
   (cd "$DIR"
    mv -v -f "$BASE" "$LOWER"
   )
  fi

done
