#!/bin/sh

IFS="
"

while :; do
  case "$1" in
    -i) INPLACE="i"; shift ;;
    -*) OPTS="${OPTS+$OPTS
}$1"; shift ;;
    *) break ;;
  esac
done

FROM="$1"
TO="$2"
shift 2

FILES="$*"

STRINGS=$(strings $FILES |grep "$FROM")

ESCAPE_EXPR="s|=|\\\\=|g"

for STRING in $STRINGS; do
  REPLACEMENT=$(echo "$STRING" | sed "s|$FROM|$TO|g")

  [ "$STRING" = "$REPLACEMENT" ] && continue

  STRING=`echo "$STRING" | sed "$ESCAPE_EXPR"`
  REPLACEMENT=`echo "$REPLACEMENT" | sed "$ESCAPE_EXPR"`

 (set -x
 bsed  -z0$INPLACE "$STRING=$REPLACEMENT" $FILES)
done
