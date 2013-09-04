#!/bin/bash

while :; do
  case "$1" in
      -e) MUST_EXIST=true; shift ;; 
    *) break ;;
  esac
done
FILTERCMD="sed -u 's,/files.list:,/,'"

if [ "$MUST_EXIST" = true ]; then
  FILTERCMD="$FILTERCMD | while read -r FILE; do test -e \"\$FILE\" && echo \"\$FILE\"; done"
fi

grep -i -E "($(IFS="|$IFS"; set -- $*; echo "$*"))" /m*/*/files.list | eval "$FILTERCMD"
