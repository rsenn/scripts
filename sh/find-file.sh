#!/bin/sh
#
# -*-mode: shell-script-*-
#
# find-file.sh
#
# Copyright (c) 2009  <enkilo@blacksun>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2009-03-18  <enkilo@blacksun>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean help "$FLAGS_FALSE"            "show this help" h
DEFINE_boolean debug "$FLAGS_FALSE"          "enable debug mode"
DEFINE_boolean ignore_case "$FLAGS_FALSE"   "case insensitivity" i
DEFINE_boolean list "$FLAGS_FALSE"   "list using 'ls'" l
DEFINE_boolean directories "$FLAGS_FALSE"   "list directories containing found files" d
DEFINE_boolean filename "$FLAGS_FALSE" "search only by filename (not path)" f

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}


usage()
{
  echo "$FLAGS_HELP" 1>&2
  exit ${1-0}
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  unset ARGS
  ANY=.
  IFS="
"

  [ "$FLAGS_filename" = "$FLAGS_TRUE" ] && ANY="[^/]"

  if [ "$#" -le 0 -o "$FLAGS_HELP" = "$FLAGS_TRUE" ]; then
    usage
  fi

  pushv ARGS -r

  while [ "$#" -gt 0 ]; do
    ARG="$1"
    case $1 in
      *[\*\?.]*)
        ARG=`fn2re "$1" "$ANY"`'$' 
    esac
    pushv ARGS "$ARG"
    shift
  done

  if [ "$FLAGS_ignore_case" = "$FLAGS_TRUE" ]; then
    ARGS="-i
$ARGS"
  fi

  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && set -x

  # now here do something

  locate -e $ARGS | {
    COUNT=0
    PREV=
    CMD='echo "$LINE"'

    if [ "$FLAGS_list" = "$FLAGS_TRUE" ]; then
      CMD='ls -lad "$LINE"'
    fi
   
    output()
    {
      (LINE="$PREV" && eval "$CMD")
    }

    while read LINE; do
     [ "$FLAGS_directories" = "${FLAGS_TRUE:-0}" ] && LINE=`dirname "$LINE"` 
        
      [ "$LINE" = "$PREV" ] && incv COUNT || COUNT=0

      [ "$LINE" != "$PREV" ] && output

      PREV="$LINE"
    done
      [ "$LINE" != "$PREV" ] && output
  }
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
