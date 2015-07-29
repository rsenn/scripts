#!/bin/bash

PATTERNS="*.part\$ *.!??\$ INCOMPL[^/]\$"

cr=""
exec grep -iE "($(IFS="| $IFS"; set $PATTERNS; echo "$*"))"  "$@"
