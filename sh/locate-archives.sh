#!/bin/bash

locate_archives()
{
    (IFS="
 "; EXTS="rar zip 7z cab tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tgz txz tbz2 tlzma"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_archives "$@"
