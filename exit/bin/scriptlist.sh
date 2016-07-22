#!/bin/bash

EXCLUDE="bash_*.sh scriptlist.sh"
IFS="
"

while :; do
  case "$1" in
    -i | --in-place) INPLACE=true; shift ;;
    *) break ;;
  esac
done

list() 
{ 
   (TAB="	" EOL='\\'
    [ $# -gt 1 ] && echo " $EOL"
    while [ "$1" ]; do
      [ $# -eq 1 ] && EOL=""
      echo "${TAB}$1${EOL:+ $EOL}"
      shift
    done)
}
ARGS="$*"

ex() { (IFS="| $IFS"; set -- $EXCLUDE; echo "($*)"); }

set -- *.{sh,awk,fontforge,bash,pl,py,rb,el}
PATTERNS="$*"

LIST=$(list `ls -d -- $PATTERNS | sort -u | ${GREP-grep
-a
--line-buffered
--color=auto} -v '^\*\.'` |grep -v -E "$(ex $EXCLUDE)")

IFS="
"
. require.sh; require var; var_dump LIST 1>&2
set -- $LIST
OUT=
BS='\\'
NL='\n'
for LINE; do
  OUT="${OUT:+$OUT$NL}$LINE"
done
VAR_N="SCRIPTS"
SED_S="/^${VAR_N}\s*=/ {
  :lp
  /${BS}\$/ { N; b lp; }
  s|=.*|= $OUT|
#  i\
#start of new scripts
#  a\
#end of new scripts
}"
#SED_S=${SED_S//"$BS"/"$BS$BS"}
${SED-sed} "$SED_S" $ARGS
#printf "%s\n" "$SED_S"
#echo "$SED_S"
#echo "$OUT"

