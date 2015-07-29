#!/bin/bash

NL="
"
IFS="$NL "

while :; do
  case "$1" in
    --all | -all) shift; set -- --javascript --java --csharp --ruby --python --cpp --c "$@" ;;
    --javascript | -js | --js) EXTS="${EXTS+$EXTS$NL}js"; shift ;;
    --java | -java | -j) EXTS="${EXTS+$EXTS$NL}java jpp j"; shift ;;
    --csharp | --cs | -cs) EXTS="${EXTS+$EXTS$NL}cs"; shift ;;
    --ruby | --rb | -rb | -ruby) EXTS="${EXTS+$EXTS$NL}rb"; shift ;;
    --python | --py | -py | -python) EXTS="${EXTS+$EXTS$NL}py"; shift ;;
    --c[px+][px+] | -c[px+][px+]) EXTS="${EXTS+$EXTS$NL}cc cpp cxx h hh hpp hxx"; shift ;;
    --c | -c) EXTS="${EXTS+$EXTS$NL}c h"; shift ;;
    *) break ;;
  esac
done

: ${EXTS="c cc cpp cxx h hh hpp hxx"}

cr=""
exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))(${cr}?\$|:)"  "$@"
