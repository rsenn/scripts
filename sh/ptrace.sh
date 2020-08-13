#!/bin/sh
#
# -*-mode: shell-script-*-
#
# ftrace.sh
#
# Copyright (c) 2008  <enki@vinylz>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-12-05  <enki@vinylz>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/std/var.sh
. $shlibdir/std/str.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
#. shflags
#
#DEFINE_boolean help false            "show this help" h
#
#FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
#"
#FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  IFS="
"
  unset STRACE_opt STRACE_cmd 

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -[dfhiqrtTvVx]) 
        pushv STRACE_opt "$1" 
      ;;
      -[aeopsuE]) 
        pushv STRACE_opt "$1" "$2" 
        shift
      ;;
      *)
        pushv STRACE_cmd "$1"
      ;;
    esac
    shift
  done

  unset STRACE_pidlist

  for CMD in $STRACE_cmd; do
    PROC=`pgrep -f "$CMD"`
    
    if [ "$PROC" ]; then
      pushv STRACE_pidlist $PROC
    fi
  done

  for NPID in $STRACE_pidlist; do
    if [ "$NPID" -a "$NPID" != "$$" ]; then
      pushv STRACE_opt -p"$NPID"
    fi
  done
 
  msg "Attaching to:" $STRACE_pidlist
 
  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && set -x

  exec strace $STRACE_opt
}

# ---[ EOF ]-----------------------------------------------------------------

main "$@"

#EOF
