#!/bin/sh

IFS="
"
VC_LIST=$(ls -d c:/"Program Files"*/"Microsoft Visual Studio"*/VC)
SDK_LIST=$(ls -d c:/"Program Files"*/"Microsoft SDKs"/Windows/v*)

list_options() {
  echo  "$*" | 
  ${SED-sed} \
		-e "s,.*\(Microsoft Visual Studio [^/]*\)/VC,\1," \
		-e "s,.*\(Microsoft SDKs\)/\(.*\)/\(.*\),Windows SDK \3," |
  sort -u
}

select_option() {
 (EXPR=$(echo "$*" | ${SED-sed} \
   -e "s,\\.,\\\\.,g")
    #-e "#s,[^0-9\\\\.]*\([^/]*[.0-9\\\\]\+\)[^0-9\\\\.]*,\1," \
    #-e "#s,[^0-9\\\\v.A]*\([^/]*[v.A\\\\0-9]\+\)[^0-9\\\\.A]*,\1,")
    
  SELECTION=$(echo "${LIST:-$VC_LIST
$SDK_LIST}" | ${GREP-grep -a --line-buffered --color=auto} "$EXPR" )
  set -- $SELECTION

  echo "S:" $SELECTION 1>&2
  
  [ $# -eq 1 ] && echo "$1"
  )
}

echo "Visual Studio:"  1>&2
list_options "$VC_LIST" 1>&2
echo "SDKs:" 1>&2
list_options "$SDK_LIST" 1>&2



for ARG; do
  S=$(select_option "$ARG")
  if [ ! -d "$S" ]; then
    echo "No such toolkit: $ARG" 1>&2
    exit 2
  fi
  echo "Selected: $S" 1>&2

  [ -d "$S/Include" ] && INCLUDE="${S}/Include${INCLUDE:+;$INCLUDE}"
  [ -d "$S/Lib" ] && LIB="${S}/Lib${LIB:+;$LIB}"
  [ -d "$S/Bin" ] && PATH="$(cygpath ${S}/Bin)${PATH:+:$PATH}"
done

echo "INCLUDE=\"$INCLUDE\"; LIB=\"$LIB\"; PATH=\"$PATH\"; export INCLUDE LIB PATH"
