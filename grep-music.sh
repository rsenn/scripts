#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -x | --debug) DEBUG=true; shift ;;
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff mod s3m xm it 669 mp4"
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