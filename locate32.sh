#!/bin/sh

IFS="
"

pathconv() { (IFS="/\\"; S="${2-/}"; set -- $1; IFS="$S"; echo "$*"); }
addopt() { for OPT; do OPTS="${OPTS:+$OPTS }${OPT}"; done; }

LOCATE=$(pathconv "$PROGRAMFILES")/Locate32/locate.exe
OPTS=
REGEX= NOCASE=
LOOKDIR= LOOKFILE= 
WHOLE= SIZE=

while :; do
  case "$1" in
    -p | --path) LOOKPATH="$2"; shift ;;
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -w | --wholename) WHOLE=true ;;
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

[ "$WHOLE" = true ] && addopt -w
[ "$LOOKPATH" ] && addopt -p "$(pathconv "$LOOKPATH" "\\")"

CMD="exec \"$LOCATE\" $OPTS -- \"$@\" | sed \"s|\\\\\\\\|/|g\""
echo "+ $CMD" 1>&2
eval "$CMD"
