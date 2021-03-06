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



#[ "${FILENAME:-false}" = true ] &&   CMD="$CMD | ${SED-sed} \"s|^|\${1%%[\$IFS]*}: |\""

#while [ $# -gt 0 ]; do
 (set -e
 IFS=" "
 COMPILER=${*:-cc}
 IFS="$IFS
"
## set -- $COMPILER
# IFS=" $IFS"
# COMPILER="$*"
# IFS=${IFS#" "}
 #COMPILER=${COMPILER//"${IFS:0:1}"/" "}
 #COMPILER_X=${COMPILER//"${IFS:0:1}"/"\\n"}
 echo "COMPILER='$COMPILER'" 1>&2
 echo "CMD='$CMD'" 1>&2
   eval "$CMD"
 ) || exit $?
# shift
#done
