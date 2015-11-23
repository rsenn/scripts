#!/bin/bash

IFS="
"

FROM="${1-*.alive*}"
shift

IFS="|"
ALIVE="\\[ALIVE\\]"
WHAT="${*:-$ALIVE}"
IFS="
"

${SED-sed} -n \
  -e "s,.*\[\(.*\)\].*\(http://.*\),\2 \[\1\],p" $FROM \
  | grep -E -i "($WHAT)" \
  | ${SED-sed} \
      -e 's,.\[[0-9]\+m,,g' \
  | cat | #: awk '{ print $1 }'  \
    ${SED-sed} -e 's,\s\+(,    \t,' -e 's,)\s\+\[,    \t\[,' |
    sort -k2 | 
  if [ -n "$*" ]; then
    cut -f1
  else
    cat
  fi
