#!/bin/sh
IFS="
"
ARGS="$*" OPTS= SUBDIR="yes" REMOVE="no" PREV= PASS=

set --
for ARG in $ARGS; do
  case $PREV in
    --pass|--password|-p) PASS="$ARG"; PREV=; continue ;;
  esac
  case $ARG in
    --remove) REMOVE="yes" ;;
    --pass|--password|-p) PREV="$ARG" ;;
    --pass=*|--password=*|-p=*) PASS="${ARG#*=}" ;;
    -[0-9A-Za-z]) OPTS="${OPTS:+$OPTS$IFS}$ARG" ;;
    *) set -- "$@" "$ARG" ;;
  esac
done

for ARG; do
  DIR=`dirname "$ARG"` 
  FILE=`basename "$ARG"`

  BASE=${FILE}
  BASE=${BASE%.[Zz][Ii][Pp]}
  BASE=${BASE%.[Rr][Aa][Rr]}

 (set -e && cd "$DIR"

  TYPE=`file -i "$FILE"`

  if [ "$SUBDIR" = yes ]; then
    mkdir -p "$BASE" && cd "$BASE" && FILE="../$FILE"
  fi

  if type realpath >/dev/null; then
    FILE=`realpath "$FILE"`
  fi

  case $TYPE in
    *:\ application/x-rar*) yes A | unrar x $OPTS "$FILE" 2>&1 ;;
    *:\ application/x-zip* | *:\ application/zip*) yes A | unzip $OPTS "$FILE" 2>&1 | sed -e "s/^replace [^:]*\[A\]ll, [^:]*: //" ;;
    *:\ application/x-*) aunpack $OPT "$FILE" ;;
    *) echo "Unknown archive type:" $TYPE 1>&2 && exit 1 ;;
  esac) || {
    RET="$?"
    if [ "$SUBDIR" = yes ]; then
      rm -rvf "$DIR/$BASE"
    fi
    exit $RET
  }
  
  if [ "$REMOVE" = yes ]; then
    rm -vf "$ARG" || exit $?
  fi
done
