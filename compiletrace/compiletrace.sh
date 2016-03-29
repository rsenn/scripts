#!/bin/bash

MYNAME=`basename "${0%.sh}"`
MYDIR=`dirname "$0"`
MYABSDIR=`cd "$MYDIR" && pwd`
MYBINDIR="$MYDIR/bin"
IFS=" "


CMD="$*"

export PATH="$MYBINDIR"

path_shift() {
   old_IFS="$IFS"; IFS=":" 
   set -- $PATH
   shift "$@"
   PATH="$*" 
   IFS="$old_IFS"
}


exec_next() {
	(IFS=" "; CMD="$*"
	path_shift 1  
	eval "${CMD}")
}

compiletrace() {

  export PATH="$MYBINDIR:$PATH"

  exec "$@"
}



case "$MYNAME" In
  compiletrace) compiletrace "$@" ;;
  compilecmd) exec_next "$MYNAME" "$@" ;;
esac
