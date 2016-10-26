#!/bin/bash

locate_vmdisks()
{
    (IFS="
 "; EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_vmdisks "$@"
