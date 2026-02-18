#!/bin/bash

: ${MYNAME=`basename "$0" .sh`}
nl="
"

archives_MASKS="archive"
audio_MASKS="audio"
books_MASKS="document"
fonts_MASKS="font"
images_MASKS="image"
scripts_MASKS="script"
software_MASKS="executable"
sources_MASKS="text"
videos_MASKS="video"

addmasks() {
  eval "MASKS=\"\${MASKS:+\$MASKS|}\${${1}_MASKS}\""
}

addmasks ${MYNAME#find-}

CYGPATH=` which cygpath 2>/dev/null` 
NL="
"
#: ${CYGPATH:=true}

# append <var> <value>
append()
{
  eval "shift; ${1}=\${$1:+\${$1}\${NL}}\$*"
}

find_filename()
{
	(IFS="
	 "

		[ "$#" -le 0 ] && set -- *

		set -f 
		set find "$@" $EXTRA_ARGS

		CONDITIONS=

#		for MASK in $MASKS; do
#			 [ "$CONDITIONS" ] && append CONDITIONS -or
#       append CONDITIONS -iname "*.$MASK${S}"
#		done

		CONDITIONS="-type${NL}f" #${NL}-and${NL}(${NL}${CONDITIONS}${NL})" 
		set "$@"  $CONDITIONS 

    [ "${DEBUG+set}" = set ] && echo "+ $@" 1>&2

    ([ "${DEBUG+set}" = set ] && set -x; "$@" 2>/dev/null |xargs -n10 -d "$nl" file | ${GREP-grep
-a
--line-buffered
--color=auto} -i -E ":[ \t]+(${MASKS})"
    )
	)
}

main() {
  IFS="
  "

  while :; do
	case "$1" in
            -t|--type) addmasks "$2"; shift 2 ;;
            -t*) addmasks "${1#-t}"; shift ;;
            --type=*) addmasks "${1#--*=}"; shift ;;
	  -depth | -maxdepth | -mindepth | -amin | -anewer | -atime | -cmin | -cnewer | -ctime | -fstype | -gid | -group | -ilname | -iname | -inum | -iwholename | -iregex | -links | -lname | -mmin | -mtime | -name | -newer | -path | -perm | -regex | -wholename | -size | -type | -uid | -used | -user | -xtype | -context | -printf | -fprint0 | -fprint | -fls) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1$NL$2"; shift 2 ;;
	  -print | -daystart | -follow | -regextype | -mount | -noleaf | -xdev | -ignore_readdir_race | -noignore_readdir_race | -empty | -false | -nouser | -nogroup | -readable | -writable | -executable | -true | -delete | -print0 | -ls | -prune | -quit) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1"; shift ;;
	  -c|--completed) COMPLETED="true"; shift ;;
	  -x|-d|--debug) DEBUG="true"; shift ;;
	  *) break ;;
	esac
  done

    #[ "${DEBUG+set}" = set ] && echo "MASKS='$MASKS'" 1>&2
    [ -z "$MASKS" ] && {
    echo "No type specified: use -t or --type" 1>&2
    exit 1
}


  ARGS="$*"

  set -- ''

  if ! ${COMPLETED-false}; then
	set -- "$@" '*.part' '.!??'
  fi

  for S; do
	S="$S" find_filename $ARGS
  done
}

main "$@"
