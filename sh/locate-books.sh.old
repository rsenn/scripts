#!/bin/bash

locate_books()
{
    (IFS="
 "; EXTS="pdf epub mobi azw3 djv djvu"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_books "$@"
