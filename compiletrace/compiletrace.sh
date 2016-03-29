#!/bin/bash

MYPATH=`realpath "$0"`
MYNAME=`basename "${0%.sh}"`
MYDIR=`dirname "$MYPATH"`
MYABSDIR=`cd "$MYDIR" && pwd`
MYBINDIR="$MYABSDIR/bin"
IFS=" "


CMD="$*"

path_shift() {
   old_PATH="$PATH" old_IFS="$IFS"; IFS=":" 
   set -- $PATH
   shift "$@"
   PATH="$*" 
   "$@"
   IFS="$old_IFS"
   PATH="$old_PATH"
}


exec_next() {
	(IFS=" "; CMD="$*"
	path_shift 1  
echo "${CMD}" >>"$COMPILETRACE_LOG"
	eval "${CMD}")
}

compiletrace() {

  
(set -x; 
   env COMPILETRACE_LOG="$COMPILETRACE_LOG" PATH="$MYBINDIR:$PATH"  "$@")
}

compilecmd() {
  :
echo "+++ $@" |tee "$COMPILETRACE_LOG" 1>&2
}

  : ${COMPILETRACE_LOG="$PWD/$MYNAME-$$.log"}
  touch "$COMPILETRACE_LOG"
export COMPILETRACE_LOG

case "$MYNAME" in
  compiletrace) compiletrace "$@" ;;
  *) compilecmd "$MYNAME" "$@" ;;
esac
