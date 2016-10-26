#!/bin/bash
NL="
"

MYNAME=`basename "$0" .sh`
MYDIR=`dirname "$0"`

  EXTS="sh py rb bat cmd"

CYGPATH=` which cygpath 2>/dev/null` 
: ${CYGPATH:=true}

find_scripts()
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

find_scripts()
{

for S in '' '*.part' '.!ut'; do
  S="$S" find_scripts "$@"
done
}


grep_scripts()
{

  exec ${GREP-grep
-a
--line-buffered
--color=auto} -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
}


locate_scripts()
{
    (IFS="
 "; 

  [ $# -le 0 ] && set -- ".*"
  for ARG; do locate -i -r "$ARG"; done |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

$MYNAME "$@"
