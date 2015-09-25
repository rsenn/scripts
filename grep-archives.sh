#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -x | --debug) DEBUG=true; shift ;;
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
     -b | -c | -F | -G | -n | -o | -P | -q | -R | -s | -T | -U | -v | -w | -x | -z) GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
}$1"; shift ;;
    *) break ;;
  esac
done

EXTS="rar zip 7z cab tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tgz txz tbz2 tlzma"

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