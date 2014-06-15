#!/bin/bash

PATTERNS="*.part\$ *.!??\$ INCOMPL[^/]\$"

exec grep -iE "($(IFS="| $IFS"; set $PATTERNS; echo "$*"))"  "$@"
