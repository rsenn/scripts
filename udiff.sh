#!/bin/bash

# parse args
name=${0##*/}
args=$(getopt -n"$name" --options "0123456789aAbBcC:dD:eEfF:hHiI:lL:nNpPqrsS:tTuU:vwW:x:X:y" -- "$@") || exit 1
orig_args=$(echo "$*")
autotools=false

prefix="/usr"
libdir="$prefix/lib"
shlibdir="$libdir/sh"

source $shlibdir/util.sh

eval "set -- $args"

# skip past options
i=1 args= IFS="
"

while test "$#" -gt 2 && test -n "$1"
do
  case $1 in
    -A) 
      autotools=true
      ;;

    --)
      shift
      break
      ;;
      
     *)
      pushv args "$1"
      ;;
  esac

  : $((i++))

  shift
done

set -- $args -- "$@"

echo args: $*

argc=$(($# - $i))

eval "arg1=\$$((i+1))"
eval "arg2=\$$((i+2))"

#echo "arg1: $arg1"
#echo "arg2: $arg2"
#echo "ret: $?"
#echo "argc: $argc"
#echo "$args"

#options="-ru"
#set -- $options "$@"


#exclusions=(".*" "aux_" "CVS" "*.rej" "*.lo" "*.la" "*.o" "*.a" "*.log" "*.cache" "*.status")

if $autotools
then
  exclusions=(
    "*/Makefile" 
    "*/Makefile.in"
    "*/.libs/*"
    "*/.deps/*"
    "*.l[ao]"
    "*.Plo"
    "*.lineno"
    "*/aclocal.m4"
    "*/config.h"
    "*/install-sh"
    "*/missing"
    "*/mkinstalldirs"
    "*/stamp-h*"
    "*/config.cache"
    "*/config.log"
    "*/config.status"
    "*/autom4te.cache/*"
    "*/config.guess"
    "*/config.sub"
    "*/ltmain.sh"
    "*/configure"
    "*/libtool"
    "*/m4/lt*.m4"
    "*~"
    "*/libtool.m4"
    "*/depcomp"
    "*/config.h.in"
    "*.alias"
    "*.sed"
    "*/stamp*"
    "*.lt"
    "*/POTFILES"
    "*.pc"
    "*/*.dir/*"
    "*/CMakeCache.txt"
    "*/CMakeFiles/Makefile.cmake"
    "*/.git*"
  )
fi

#detected_exclusions=$(for dir in "$arg1" "$arg2"; do
#  test -d "$dir" && find "$dir" -type f -name "*.in" -and -not -name "configure.in" -and -not -name "config.h.in";
#done | sed 's,^.*/\(.*\)\.in$,\1,' | sort -u)

#for x in $detected_exclusions; do
#  exclusions[${#exclusions[@]}]="$x"
#done

chain='diff "$@"'
filter=

chain="${chain} 2>&1|grep -vE '^(Only|Binary|Files.*differ\$)'"

for exclusion in "${exclusions[@]}"
do
  verbose "Excluding '$exclusion'"

  pushv filter -x "$exclusion"
done

if test -n "$filter"
then
  IFS='|' pushv chain 'filterdiff $filter'
fi

set -f 

eval "$chain"
