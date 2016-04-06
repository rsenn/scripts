#!/bin/bash

IFS="
"
: ${level:=3}
: ${EXCLUDE:="*.git*
*~
*.stackdump
build/*
*.orig
*.rej
*.tmp
.[oa]
.obj
config.status
CMakeCache.txt"}


pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

main() {
	ARGS="$*"

	case "$EXCLUDE" in
		*"
	"*) ;; 
		*\ *) IFS="$IFS "; set -f ; set -- $EXCLUDE;  EXCLUDE="$*"; set +f; IFS="
	" ;;
	esac
	set -- $ARGS

	while :; do
		case "$1" in
			-[0-9]) level=${1#-}; shift ;;
			-t) type=$2; shift 2 ;;
			-x | --debug) DEBUG=true; shift ;;
			-q | --quiet) QUIET=true; shift ;;
			-r | --remove*) REMOVE=true; shift ;;
			-d=* | --dest*dir*=*) DESTDIR=${1#*=}; shift ;; 
			-d | --dest*dir*) DESTDIR=$2; shift 2 ;;
			-D | --no*date*) nodate=true; shift  ;;
			-[EX] | --exclude) pushv EXCLUDE "$2"; shift 2 ;; 
			-[EXx]*) pushv EXCLUDE "${1#-?}"; shift ;; 
			-[EXx]=*) pushv EXCLUDE "${1#*=}"; shift ;;
			-e=* | --exclude=*) pushv EXCLUDE "${1#*=}"; shift ;;
			-x | --debug) DEBUG=true; shift ;;
			*) break ;;
		esac
	done

	type gtar 2>/dev/null >/dev/null && TAR=gtar ||
	{ type gtar 2>/dev/null >/dev/null && TAR=gtar; }
	: ${TAR=tar}



	[ "$DESTDIR" ] &&
	ABSDESTDIR=`cd "$DESTDIR" && pwd`


	while [ -d "$1" ]; do
		dirs="${dirs:+$dirs
	}$1"; shift
	done


	[ "$DEBUG"  = true ] && echo "+ dirs="$@ 1>&2 
	while [ $# -gt 0 ]; do

		if [ "$1" ]; then
			case "$1" in
				*.tar*|*.7z|*.rar|*.zip|*.t?z|*.cpio)   archive=$1; shift ;;
			esac
		fi
	done

	DIR1=$(set -- $dirs; echo "${1##*/}")

	WD=${PWD}

	if [ -n "$DIR1" -a "${DIR1#$WD}" != "${DIR1}" ]; then
		dname=${DIR1#$WD}
		dname=${dname#[\\/]}
	else
		dname="${WD}"
	fi

	#echo "dname=$dname" 1>&2 
	dir=${2:-.}

	if [ -z "$archive" ]; then
		
		if [ "$DESTDIR" ]; then
			name=${dname#$ABSDESTDIR}
			name=${name#/}
			name=${name//[\\/]/-}
		else
			name=${dname##*/}
		fi
		name=${name#.}
		name=${name%/}
		#echo "name=$name" 1>&2 

		archive=${DESTDIR:-..}/${name##*/}
		[ "$nodate" != true ] && archive=$archive-$(isodate.sh -r ${dir:-.})   #`date ${dir:+-r "$dir"} +%Y%m%d`
		archive=$archive.${type:-7z}
	fi
	set -f
	case "$archive" in
		*.iso) cmd="${genisoimage:-mkisofs} -f -l -R -J -o \"\$archive\"  $(create_list "-exclude " $EXCLUDE) \"$dir\"" ;;
		*.7z) cmd="${sevenzip:-7za} a -mx=$(( $level * 5 / 9 )) \"\$archive\" $(create_list "-x!" $EXCLUDE) \"$dir\"" ;;
                *.zip) cmd="zip -${level} $(test "$REMOVE" = true && echo -m) -r \"\$archive\" \"$dir\" $(create_list "-x " $EXCLUDE) " ;;
                *.rar) cmd="rar a -m$(($level * 5 / 9)) $(test "$REMOVE" = true && echo -df) -r $(create_list "-x" $EXCLUDE) \"\$archive\" \"$dir\"" ;;
		*.txz|*.tar.xz) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents \"$dir\") | xz -$level >\"\$archive\"" ;;
		*.tlzma|*.tar.lzma) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents "$dir") | lzma -$level >\"\$archive\"" ;;
		*.tlzip|*.tar.lzip) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents "$dir") | lzip -$level >\"\$archive\"" ;;
		*.tlzo|*.tar.lzo) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents "$dir") | lzop -$level >\"\$archive\"" ;;
		*.tgz|*.tar.gz) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents "$dir") | gzip -$level >\"\$archive\"" ;;
		*.tbz2|*.tbz|*.tar.bz2) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) $(dir_contents "$dir") | bzip2 -$level >\"\$archive\"" ;;
	esac
	cmd='rm -vf "$archive";'$cmd
	[ "$QUIET" = true ] && cmd="($cmd) 2>/dev/null" || cmd="($cmd) 2>&1"
	echo "cmd='$cmd'" 1>&2
	eval "(test \"\$DEBUG\" = true && set -x; $cmd)" &&
	echo "Created archive '$archive'"
}

bce() {
 (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | ${SED-sed} -u '/\./ s,\.\?0*$,,'
}

bci() {
 (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | ${SED-sed} -u 's,\.[0-9]\+$,,'
}

create_list() {
 (output=
  SWITCH="$1"
  shift
  for arg; do
    output="${output:+$output }${SWITCH}$arg"
  done
  echo "$output")
}

match() {
	(while :; do
	  case "$1" in
			-v | --invert*) INVERT=true; shift ;;
			*) break ;;
		esac
	done
  EXPR="$1"; shift
  [ "$INVERT" = true ] && EXPR=$EXPR' ) ;;
*' 
  CMD='case $LINE in
  '$EXPR') echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

implode()
{
 (unset DATA SEPARATOR;
  SEPARATOR="$1"; shift
  CMD='DATA="${DATA+$DATA$SEPARATOR}$ITEM"'
  if [ $# -gt 0 ]; then
    CMD="for ITEM; do $CMD; done"
  else
    CMD="while read -r ITEM; do $CMD; done"
  fi
  eval "$CMD"
  echo "$DATA")
}

dir_contents() {
(echo "dir_contents \"$(implode '" "' "$@")\"" 1>&2
  case "$1" in 
		. | "." | \".\" | .*) 
			EXCLUDE="$(implode "|" $EXCLUDE)" 
			set -- $(ls -a -1 |grep -v -E '^(\.|\.\.)$' |sort -u |match -v "${EXCLUDE:-''}")
			;;
		*)
		  ;;
	esac 
	
  IFS=" "; echo "$*")
}

main "$@"
