#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -x | --debug) DEBUG=true; shift ;;
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
cr=""

CMD='grep $GREP_ARGS -i -E "\\.($(IFS="| "; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}${cr}?\$"  "$@"'

if [ $# -gt 0 ]; then
  GREP_ARGS="-H"
  case "$*" in
    *files.list*) FILTER='sed "s|/files.list:|/|"' ;;
  esac
fi

[ -n "$FILTER" ] && CMD="$CMD | $FILTER" || CMD="exec $CMD"
[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2

eval "$CMD"