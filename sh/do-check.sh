#!/bin/bash
NL="
"
LIST="$1"
NAME=${LIST%.list}
EXPR=${NAME//[!0-9A-Za-z]/.*}

if [ -z "$2" ]; then
  CTX=20
fi

URLS=`grep -E -i ${CTX:+-C "$CTX"} "(${2-$EXPR})" "$LIST" | ${GREP-grep
-a
--line-buffered
--color=auto} -v '^-'`
IFS="
"

set -- $URLS
echo "Got $# URLs" 1>&2
 
slimrat -c $URLS | tee "$NAME".alive
wc -l "$NAME".alive 1>&2

