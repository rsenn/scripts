#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
NL="
"
#: ${CYGPATH:=true}

# append <var> <value>
append()
{
  eval "shift; ${1}=\${$1:+\${$1}\${NL}}\$*"
}

find_videos()
{
	(IFS="
	 "
		EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"

		[ "$#" -le 0 ] && set -- *

		set -f 
		set find "$@" 

		CONDITIONS=

		for EXT in $EXTS; do
			 [ "$CONDITIONS" ] && append CONDITIONS -or
       append CONDITIONS -iname "*.$EXT${S}"
		done

		CONDITIONS="-type${NL}f${NL}(${NL}${CONDITIONS}${NL})" 
		set "$@"  $CONDITIONS 

    ${DEBUG-false} && echo "+ $@" 1>&2

    
		("$@" 2>/dev/null)  |sed -u 's,^\.\/,,'
	)
}

IFS="
"

while :; do
  case "$1" in
    -c|--completed) COMPLETED="true"; shift ;;
    -C|--incomplete) INCOMPLETE="true"; shift ;;
    -x|-d|--debug) DEBUG="true"; shift ;;
    *) break ;;
  esac
done

ARGS="$*"

if [ "$INCOMPLETE" = true ]; then
	set -- 
else
  set -- ''
fi

if [ "$COMPLETED" != true ]; then
  set -- "$@" '*.part' '.!??'
fi

for S; do
  S="$S" find_videos $ARGS
done
