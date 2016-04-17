#!/bin/bash
NL="
"

PATTERNS="*.part\$ *.!??\$ INCOMPL[^/]\$"

cr=""
exec ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -iE "($(IFS="| $IFS"; set $PATTERNS; echo "$*"))"  "$@"
