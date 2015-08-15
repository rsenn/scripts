#!/bin/bash

IFS="
"
level=3
: ${exclude="*.git*
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
while :; do
  case "$1" in
    -[0-9]) level=${1#-}; shift ;;
    -t) type=$2; shift 2 ;;
    -d=* | --dest*dir*=*) DESTDIR=${1#*=}; shift ;; -d | --dest*dir*) DESTDIR=$2; shift 2 ;;
    -D | --no*date*) nodate=true; shift  ;;
    -[EXx]) pushv exclude "$2"; shift 2 ;; -[EXx]=*) pushv exclude "${1#*=}"; shift ;;
    -[EXx] | --exclude) pushv exclude "$2"; shift 2 ;; -e=* | --exclude=*) pushv exclude "${1#*=}"; shift ;;
    *) break ;;
  esac
done

type gnutar 2>/dev/null >/dev/null && TAR=gnutar ||
{ type gtar 2>/dev/null >/dev/null && TAR=gtar; }
: ${TAR=tar}



[ "$DESTDIR" ] &&
ABSDESTDIR=`cd "$DESTDIR" && pwd`


if [ "$1" ]; then
  case "$1" in
    *.tar*|*.7z|*.rar|*.zip|*.t?z|*.cpio)   archive=$1; shift ;;
  esac
fi

while [ -d "$1" ]; do
  dirs="${dirs:+$dirs
}$1"; shift
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
  [ "$nodate" != true ] && archive=$archive-`date ${dir:+-r "$dir"} +%Y%m%d`
  archive=$archive.${type:-7z}
fi
dir=${2-.}

bce() {
 (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | sed -u '/\./ s,\.\?0*$,,'
}

bci() {
 (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | sed -u 's,\.[0-9]\+$,,'
}

create-list() {
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

dir-contents() {
(echo "dir-contents \"$(implode '" "' "$@")\"" 1>&2
  case "$1" in 
		. | "." | \".\" | .*) 
			EXCLUDE="$(implode "|" $exclude)" 
			set -- $(ls -a -1 |grep -v -E '^(\.|\.\.)$' |sort -u |match -v "${EXCLUDE:-''}")
			;;
		*)
		  ;;
	esac 
	
  IFS=" "; echo "$*")
}

set -f
case "$archive" in
  *.7z) cmd="${sevenzip:-7za} a -mx=$(( $level * 5 / 9 )) \"\$archive\" $(create-list "-x!" $exclude) \"$dir\"" ;;
  *.zip) cmd="zip -${level} -r \"\$archive\" \"$dir\" $(create-list "-x " $exclude) " ;;
  *.rar) cmd="rar a -m$(($level * 5 / 9)) -r $(create-list "-x" $exclude) \"\$archive\" \"$dir\"" ;;
  *.txz|*.tar.xz) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents \"$dir\") | xz -$level >\"\$archive\"" ;;
  *.tlzma|*.tar.lzma) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents "$dir") | lzma -$level >\"\$archive\"" ;;
  *.tlzip|*.tar.lzip) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents "$dir") | lzip -$level >\"\$archive\"" ;;
  *.tlzo|*.tar.lzo) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents "$dir") | lzop -$level >\"\$archive\"" ;;
  *.tgz|*.tar.gz) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents "$dir") | gzip -$level >\"\$archive\"" ;;
  *.tbz2|*.tbz|*.tar.bz2) cmd="$TAR -cv $(create-list --exclude= $exclude) $(dir-contents "$dir") | bzip2 -$level >\"\$archive\"" ;;
esac
cmd='rm -vf "$archive";'$cmd
cmd="($cmd) 2>&1"
echo "cmd='$cmd'" 1>&2
eval "(set -x; $cmd)" &&
echo "Created archive '$archive'"
