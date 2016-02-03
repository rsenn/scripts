#!/bin/bash

MYNAME=`basename "$0" .sh`
MYDIR=`dirname "$0"`

EXTS="afm bdf fon gsf otf pcf pfa pfb pfm ttc ttf"

CYGPATH=` which cygpath 2>/dev/null` 
: ${CYGPATH:=true}

find_fonts()
{
	(
   IFS="
	 "
		
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

		"$@" 2>/dev/null  |${SED-sed} -u 's,^\.\/,,' |while read -r P; do
		( 
			${CYGPATH:+$CYGPATH -m "$P"}
		)
		done
	)
}

find_fonts()
{

for S in '' '*.part' '.!ut'; do
  S="$S" find_fonts "$@"
done
}


grep_fonts()
{
  exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
}


locate_fonts()
{
    (IFS="
 ";
 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

$MYNAME "$@"
