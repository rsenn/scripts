#!/bin/bash

locate_sources()
{
    (IFS="
 "; EXTS="c cpp cxx h hpp hxx"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_sources "$@"
