#!/bin/sh
NL="
"
IFS="${NL}:"

while :; do
  case "$1" in
    -x) DEBUG=true; shift ;;
    *) break ;;
  esac
done

ARGS="$*"
NM_S=`for P in $PATH; do ls -d "$P"/*-nm; done 2>/dev/null`

set -- `for MATCH in cygwin msys mingw; do echo "$NM_S" | grep -i "$MATCH" ; done`

for NM; do
EXPORTS=`
"$NM" $ARGS 2>/dev/null | sed -n "s|.* T _||p"
`
  if [ "$EXPORTS" ]; then
[ "$DEBUG" = true ] && echo "NM is $NM" 1>&2 
    break
  fi
done

 
echo "$EXPORTS" | sed -e "1 i\\${NL}EXPORTS" -e "s|^|  |"

