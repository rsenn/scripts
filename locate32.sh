#!/bin/sh

pathconv() { (IFS="/\\"; set -- $*; echo "$*"); }
addopt() { OPTS="${OPTS:+$OPTS }$*"; }

LOCATE=$(pathconv "$PROGRAMFILES")/Locate32/locate.exe
OPTS=
REGEX= NOCASE=
LOOKDIR= LOOKFILE= LOOKWHOLE=
SIZE=

while :; do
  case "$1" in
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -w | --wholename) LOOKWHOLE=w ;;
    -s | 	--size) SIZE="$2"; shift ;;
    *) break ;;
  esac
  shift
done

case "${NOCASE:-false}:${REGEX:-false}" in
  true:false) addopt -lcn ;;
  true:true) addopt -rc ;;
  false:true) addopt -r ;;
esac

if [ -z "${LOOKFILE}${LOOKDIR}${LOOKWHOLE}" ]; then
  LOOKFILE=f
fi

addopt -l"${LOOKFILE}${LOOKDIR}${LOOKWHOLE}"
addopt -lrn

case "$SIZE" in
  +*) addopt -lm:"${SIZE#?}" ;;
  -*) addopt -lM:"${SIZE#?}" ;;
esac

"$LOCATE" $OPTS -- "$@" | sed "s|\\\\|/|g"
