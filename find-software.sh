#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
: ${CYGPATH:=true}

find_music()
{
	(
   IFS="
	 "
		EXTS="*setup*.exe *install*.exe *.msi"
		
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
	*.$EXT${S}"
		done

		CONDITIONS="$CONDITIONS
	-and -type f -and -size +3M" 

		set "$@" "(" $CONDITIONS ")" 

		"$@" 2>/dev/null  |sed -u 's,^\.\/,,' |while read -r P; do
		( 
			${CYGPATH:+$CYGPATH -m "$P"}
		)
		done
	)
	}

for S in '' '*.part' '.!ut'; do
  S="$S" find_music "$@"
done
