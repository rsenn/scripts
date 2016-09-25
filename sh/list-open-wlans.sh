#!/bin/sh
IF=wlan0

if [ "`id -u`" != 0 ]; then
  echo "Must be root!" 1>&2
  exit 1
fi

push()
{
  OUTPUT="${OUTPUT+$OUTPUT${IFS%%${IFS#?}}}$*"
}

iwlist "$IF" scanning | 
grep -i -B6 -A1 KEY:off |
while read line; do
  case $line in
    *Cell*[0-9]*)
      CELL=${line%%" - "*}
      push CELL=${CELL#*Cell?}
    ;;
    --*)
      echo "$OUTPUT"
      OUTPUT=
    ;;
    *)
      NAME=${line%%[:=]*}
      VALUE=${line#*[:=]}
        case "$VALUE" in
          '"'*'"') ;;
          ' '*) VALUE=`echo $VALUE` ;;
          *) VALUE='"'$VALUE'"' ;;
        esac
      NAME=`echo "$NAME" | tr "[:lower:] " "[:upper:]_"`
      push $NAME="$VALUE"
    ;;
  esac
done

[ "$OUTPUT" ] && echo "$OUTPUT"
