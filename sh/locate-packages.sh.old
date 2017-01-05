#!/bin/bash

locate_packages()
{
    (IFS="
 "; EXTS="rpm deb txz tgz"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_packages "$@"
