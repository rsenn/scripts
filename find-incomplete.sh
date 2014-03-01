#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
#: ${CYGPATH:=true}

find_incomplete()
{
	(
   IFS="
	 "
		EXTS="*.part *.!?? INCOMPL*"

		[ "$#" -le 0 ] && set -- *

		set -f 

		set find "$@" 

		CONDITIONS=

		for EXT in $EXTS; do
			 if [ "$CONDITIONS" ]; then
				 CONDITIONS="$CONDITIONS
-or"
			 fi
			 CONDITIONS="$CONDITIONS
-iname
$EXT${S}"
		done

		CONDITIONS="-not -type d
(
$CONDITIONS
)" 

		set "$@"  $CONDITIONS 

		(set +x; "$@" 2>/dev/null)  |sed -u 's,^\.\/,,'
	)
	}

find_incomplete "$@"
