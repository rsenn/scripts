#!/bin/bash
IFS="
"
spc=" "
bs="\\"
: ${level:=3}
: ${EXCLUDE="*.git*
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

max-length () 
{ 
    ( max=$1;
    shift;
    a=$*;
    l=${#a};
    [ $((l)) -gt $((max)) ] && a="${a:1:$((max - 3))}...";
    echo "$a" )
}
cmdexec()  { 
   (IFS=" ""
    " R= C= E='eval "$C"' EE=': ${R:=$?}; [ "$R" = "0" ] && unset R'
    [ "$DEBUG" = true ] && E='eval "echo \"XX: \$C\"" 1>&2;'$E
    o() {  X_RM_O="${X_RM_O:+$X_RM_O$IFS}$1"; E="exec >>'$1'; $E"; }
    while [ $# -gt 0 ]; do case "$1" in 
                -o) o "$2"; shift 2 ;; -o*) o "${1#-o}"; shift ;;
            -w) E="(cd '$2' && $E)"; shift 2 ;;     -w*) E="(cd '${1#-w}' && $E)"; shift ;;
            -m) E="$E 2>&1"; shift ;;
        *) break ;;
        esac;  done;  C="$*"; #EC=`max-length $max_length "$C"`; [ "$DEBUG" = true ] && eval max-length $max_length "EVAL: $E" 1>&2 
#    (trap "$EE;  [ \"\$R\" != 0 ] && echo \"\${R:+\$IFS!! (exitcode: \$R)}\" 1>&2 || echo 1>&2; exit \${R:-0}" EXIT
    eval "echo -n \"@@ $C\" 1>&2";  eval "($E); $EE";  exit ${R:-0}) ; return $?
}
debug()
{
    [ "$DEBUG" = true ] && echo "DEBUG: $@" 1>&2
}
verbose() {
   (M="$*" A=`eval "echo \"\${$#}\""` IFS="
";
    if [ "$#" = 1 ]; then
        A=1;
    fi;
    if ! [ "$A" -ge 0 ]; then
        A=0;
    fi 2> /dev/null > /dev/null;
    if [ $(( ${VERBOSE:-0} )) -ge "$A" ]; then
        M "${M%?$A}";
    fi)
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

make_archive() {
	ARGS="$*"
        : ${max_length=120}
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
                    -v | --verbose) VERBOSE=$(( ${VERBOSE:-0} + 1 )); shift ;;
			-q | --quiet) QUIET=true; shift ;;
			-r | --remove*) REMOVE=true; shift ;;
			-d=* | --dest*dir*=*) DESTDIR=${1#*=}; shift ;; 
			-d | --dest*dir*) DESTDIR=$2; shift 2 ;;
			-D | --no*date*) nodate=true; shift  ;;
			-[EX] | --exclude) pushv EXCLUDE "$2"; shift 2 ;; 
			-[EXx]*) pushv EXCLUDE "${1#-?}"; shift ;; 
			-[EXx]=*) pushv EXCLUDE "${1#*=}"; shift ;;
			-e=* | --exclude=*) pushv EXCLUDE "${1#*=}"; shift ;;
			*) break ;;
		esac
	done
        case "$type" in
            *xz*) level=$((level * 6 / 9)) ;;
        esac
	type gtar 2>/dev/null >/dev/null && TAR=gtar ||
	{ type gtar 2>/dev/null >/dev/null && TAR=gtar; }
	: ${TAR=tar}
	[ "$DESTDIR" ] &&
	ABSDESTDIR=`cd "$DESTDIR" && pwd`
	while [ -d "$1" ]; do
		dirs="${dirs:+$dirs
}$1"; shift
	done
	debug "+ dirs="$@ 
	while [ $# -gt 0 ]; do
		if [ "$1" ]; then
			case "$1" in
				*.tar*|*.7z|*.rar|*.zip|*.t?z|*.cpio)   archive=$1; shift ;;
			esac
		fi
	done
	DIR1=$(set -- ${dir//$spc/$bs$spc}s; echo "${1##*/}")
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
        elif [ -n "$archive" -a -f "$archive" ]; then
            if [ "$FORCE" != true ]; then
            verbose "Archive '$archive' already exists!" 0
            exit 1
        fi
	fi
	set -f
	case "$archive" in
		*.iso) cmd="${genisoimage:-mkisofs} -f -l -R -J -o \"\$archive\"  $(create_list "-exclude " $EXCLUDE) \$dir" ;;
		*.7z) cmd="${sevenzip:-7za} a -mx=$(( $level * 5 / 9 )) \"\$archive\" $(create_list "-x!" $EXCLUDE) \$dir" ;;
                *.zip) cmd="zip -${level} $(test "$REMOVE" = true && echo -m) -r \"\$archive\" \$dir $(create_list "-x " $EXCLUDE) " ;;
                *.rar) cmd="rar a -m$(($level * 5 / 9)) $(test "$REMOVE" = true && echo -df) -r $(create_list "-x" $EXCLUDE) \"\$archive\" \$dir" ;;
		*.tar) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) -f \"\$archive\"" ;;
		*.txz|*.tar.xz) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | xz -$level >\"\$archive\"" ;;
		*.tlzma|*.tar.lzma) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | lzma -$level >\"\$archive\"" ;;
		*.tlzip|*.tar.lzip) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | lzip -$level >\"\$archive\"" ;;
		*.tlzo|*.tar.lzo) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | lzop -$level >\"\$archive\"" ;;
		*.tgz|*.tar.gz) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | gzip -$level >\"\$archive\"" ;;
		*.tbz2|*.tbz|*.tar.bz2) cmd="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${dir//$spc/$bs$spc}) | bzip2 -$level >\"\$archive\"" ;;
	esac
	cmd='rm -vf -- "$archive"; '$cmd
	[ "$QUIET" = true ] && cmd="($cmd) 2>/dev/null" || cmd="($cmd) 2>&1"

        verbose "cmd='$(max-length $max_length "$cmd")'" 2
        IFS="$IFS "
	cmdexec $cmd  &&
	verbose "Created archive '$archive'" 1
}

bce() {
 (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | ${SED-sed} -u '/\./ s,\.\?0*$,,'
}

bci() {
 (IFS=" "; : debug "EXPR: bci '$*'" ; bce "($*) + 0.5") | ${SED-sed} -u 's,\.[0-9]\+$,,'
}

create_list() {
 ( 
 #: ${separator=" "}
 : ${separator="','"}
  #output=
  output="$1{'"
  shift
  list=
  [ $# -gt 0 ] && {
  for arg; do 
    list="${list:+$list$separator}$arg"
  done
  output="$output$list'}"
  echo "$output"
  } )
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

implode () 
{ 
    ( unset D S C I;
    S="$1";
    shift;
    C='D="${D+$D$S}$I"';
    if [ $# -gt 0 ]; then
        C="for I; do $C; done";
    else
        C="while read -r I; do $C; done";
    fi;
    eval "$C";
    echo "$D" )
}

dir_contents() {
( 
#: ${SEP='" "'}
: ${SEP=' '}
verbose  "dir_contents \"$(implode "$SEP" "$@")\"" 3
  case "$1" in 
		. | "." | \".\" | .*) 
			EXCLUDE="$(implode "|" $EXCLUDE)" 
			set -- $(ls -a -1 |grep -v -E '^(\.|\.\.)$' |sort -u |match -v "${EXCLUDE:-''}")
			;;
		*)
		  ;;
	esac 
       implode "$SEP" "$@"
  #IFS=" "; echo "$*"
  )
}
make_archive "$@"
