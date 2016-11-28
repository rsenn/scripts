#!/bin/sh

N=$#
IFS="
 "
 CMD='echo | $COMPILER -dM -E -  | sort'

while :; do
  case "$1" in
    --short | -s)  
      CMD="$CMD | ${SED-sed} \"s|^\(#define\)\s\+\([^ ]\+\)\s\+\(.*\)|\2=\3| ;; s|^\(#define\) \([^ ]\+\)\\\$|\2|\""; shift ;;
    --no-filename | -h) FILENAME=false; shift ;;
    --with-filename | -H) FILENAME=true; shift ;;
  *) break ;;
esac
done

 [ "$N" -gt 1 ] && : ${FILENAME:=true}
 
[ "${FILENAME:-false}" = true ] &&  
CMD="$CMD | ${SED-sed} \"s|^|\$COMPILER: |\""

while [ $# -gt 0 ]; do
 (set -e
 COMPILER=${1:-cc}
 set -- $COMPILER
 COMPILER="$*"

   eval "$CMD"
 ) || exit $?
 shift
done
