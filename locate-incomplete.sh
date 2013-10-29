#!/bin/bash

: ${LOCATE="locate"}

locate_incomplete()
{
    (IFS="
 ";     EXTS="\\.part\$ \\.!??\$ [/\\]INCOMPL[^/\\]*\$"

 ${LOCATE:-locate} -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))"
 )
}

locate_incomplete "$@"
