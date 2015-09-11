#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
: ${CYGPATH:=true}

find_software()
{
	(
   IFS="
	 "
		EXTS="*setup*.exe *install*.exe *.msi *.msu *.cab *.vbox-extpack *.apk *.run *.dmg *.app *.apk"
    EXTS="$EXTS 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"
		
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
set -f

		set "$@" -type f -and "(" $CONDITIONS ")" 

		"$@" 2>/dev/null  |sed -u 's,^\.\/,,' 
	)
	}

for S in '' ; do
  S="$S" find_software "$@"
done
