#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
NL="
"
#: ${CYGPATH:=true}

IFS="$NL "

while :; do
  case "$1" in
    -depth | -maxdepth | -mindepth | -amin | -anewer | -atime | -cmin | -cnewer | -ctime | -fstype | -gid | -group | -ilname | -iname | -inum | -iwholename | -iregex | -links | -lname | -mmin | -mtime | -name | -newer | -path | -perm | -regex | -wholename | -size | -type | -uid | -used | -user | -xtype | -context | -printf | -fprint0 | -fprint | -fls) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1$NL$2"; shift 2 ;;
    -print | -daystart | -follow | -regextype | -mount | -noleaf | -xdev | -ignore_readdir_race | -noignore_readdir_race | -empty | -false | -nouser | -nogroup | -readable | -writable | -executable | -true | -delete | -print0 | -ls | -prune | -quit) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1"; shift ;;
    -c|--completed) COMPLETED="true"; shift ;;
    -C|--incomplete) INCOMPLETE="true"; shift ;;
    -x|-d|--debug) DEBUG="true"; shift ;;
    --all | -all) shift; set -- --javascript --java --csharp --ruby --python --cpp --c "$@" ;;
    --javascript | -js | --js) EXTS="${EXTS+$EXTS$NL}js"; shift ;;
    --java | -java | -j) EXTS="${EXTS+$EXTS$NL}java jpp j"; shift ;;
    --csharp | --cs | -cs) EXTS="${EXTS+$EXTS$NL}cs"; shift ;;
    --ruby | --rb | -rb | -ruby) EXTS="${EXTS+$EXTS$NL}rb"; shift ;;
    --python | --py | -py | -python) EXTS="${EXTS+$EXTS$NL}py"; shift ;;
    --c[px+][px+] | -c[px+][px+]) EXTS="${EXTS+$EXTS$NL}cc cpp cxx h hh hpp hxx ipp"; shift ;;
    --c | -c) EXTS="${EXTS+$EXTS$NL}c h"; shift ;;
    *) break ;;
  esac
done

: ${EXTS="c cs cc cpp cxx h hh hpp hxx ipp"}



# append <var> <value>
append()
{
  eval "shift; ${1}=\${$1:+\${$1}\${NL}}\$*"
}

find_sources()
{
	(IFS="
	 "

		[ "$#" -le 0 ] && set -- *

		set -f 
		set find "$@" $EXTRA_ARGS

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
  S="$S" find_sources $ARGS
done
