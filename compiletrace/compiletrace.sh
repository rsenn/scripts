#!/bin/bash

MYPATH=`realpath "$0"`
MYNAME=`basename "${0%.sh}"`
MYDIR=`dirname "$MYPATH"`
MYABSDIR=`cd "$MYDIR" && pwd`
MYBINDIR="$MYABSDIR/bin"
IFS=" "


CMD="$*"

path_shift() {
   old_PATH="$PATH" old_IFS="$IFS"; IFS=":"; N="$1"
   set -- $PATH
   shift $N
   IFS="$old_IFS"
   PATH="$old_PATH"
}

pathremove() { old_IFS="$IFS"; IFS=":"; RET=1; unset NEWPATH; for DIR in $PATH; do for ARG in "$@"; do case "$DIR" in $ARG) RET=0; continue 2 ;; esac; done; NEWPATH="${NEWPATH+$NEWPATH:}$DIR"; done; PATH="$NEWPATH"; IFS="$old_IFS"; unset NEWPATH old_IFS; return $RET; }

exec_next() {
	(IFS=" "; CMD="$*"
	path_shift 1  
          pathremove "$MYBINDIR"
echo "${CMD}" >>"$COMPILETRACE_LOG"
	eval "${CMD}")
}

compiletrace() {
   unset CMDS

   while [ $# -gt 0 ]; do
      A="$1"
case "$A" in
  --) A="; " ;;
esac
      CMDS="${CMDS+$CMDS }$A"
	shift
   done
  
(set -x;
export COMPILETRACE_LOG
export PATH="$MYBINDIR:$PATH"
eval "$CMDS")
}

compilecmd() {
  :
echo "$@" >>"$COMPILETRACE_LOG"
echo "+++ $@" 1>&2
exec_next "$@"
}

: ${COMPILETRACE_LOG:="$PWD/$MYNAME-$$.log"}
touch "$COMPILETRACE_LOG"
export COMPILETRACE_LOG

trap 'wc -l "$COMPILETRACE_LOG"' EXIT

case "$MYNAME" in
  compiletrace) compiletrace "$@" ;;
  *) compilecmd "$MYNAME" "$@" ;;
esac
