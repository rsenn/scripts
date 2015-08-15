#!/bin/bash

MYNAME=`basename "$0" .sh`
MYDIR=`dirname "$0"`


CYGPATH=` which cygpath 2>/dev/null` 
: ${CYGPATH:=true}

find_fonts()
{
	(
   IFS="
	 "
		EXTS="otf ttf fon bdf pcf"
		
		[ "$#" -le 0 ] && set -- *

		set -f 

		set find "$@" $EXTRA_ARGS

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

find-fonts()
{

for S in '' '*.part' '.!ut'; do
  S="$S" find_fonts "$@"
done
}


grep-fonts()
{
  EXTS="ttf otf bdf pcf fon"

  exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
}


locate-fonts()
{
    (IFS="
 "; EXTS="mp3 ogg flac mpc m4a m4b wma rm"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

$MYNAME "$@"
