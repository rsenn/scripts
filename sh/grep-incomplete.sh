#!/bin/bash
NL="
"

PATTERNS="*.part\$ *.!??\$ INCOMPL[^/]\$"

cr=""
exec ${GREP-grep -a --line-buffered --color=auto} -iE "($(IFS="| $IFS"; set $PATTERNS; echo "$*"))"  "$@"
