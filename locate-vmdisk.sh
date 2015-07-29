#!/bin/bash

locate_vmdisks()
{
    (IFS="
 "; EXTS="vdi vmdk vhd qed qcow qcow2 raw vhdx hdd"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_vmdisks "$@"
