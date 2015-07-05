#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="rar zip 7z tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tgz txz tbz2 tlzma"

exec grep -i -E "\\.($(IFS='| '; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}\$"  "$@"
