#!/bin/sh
#
# -*-mode: shell-script-*-
#
# svtail.sh
#
# Copyright (c) 2008 Roman Senn <rs@adfinis.com>
# All rights reserved.
# 
#
# 2008-10-02 Roman Senn,,, <enki@gatling>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/sys/proc.sh
. $shlibdir/std/algorithm.sh
. $shlibdir/std/var.sh
. $shlibdir/std/str.sh

# configuration values
# ---------------------------------------------------------------------------
TAIL_cmd=tail
TAIL_options=

# ---------------------------------------------------------------------------
SVTAIL_recursive=:
#SVTAIL_log=:

# ---------------------------------------------------------------------------
usage()
{
  echo "usage: ${0##*/} service-name

  -h, --help   Show this help"
  exit 0
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  while :; do
    case $1 in 
      -h | --help) usage ;;
      -*) pushv TAIL_options "$1" ;;
      *) break ;;
    esac
    shift
  done

  if test -z "$1"; then
    usage
  fi

  service=$1
  processes=`
    proc_grep "runsv .*$service\$" || 
    proc_grep "supervise .*$service\$"
  `
  if test -z "$processes"; then
    error "no process matching $service"
    exit 127
  fi

  #var_dump processes

  set -- `proc_children $processes`
  unset processes
  for pid; do
    set -- `proc_cmdline $pid`
#    echo "cmdline: $1"
    case $1 in
      svlogd | multilog) pushv processes $pid ;;
    esac
  done

  var_dump processes

  if test -z "$processes"; then
    error "process $service has no logger"
    exit 127
  fi

  set -- $processes

  # it must be exactly one process 
  if [ "$#" -gt 1 ]; then
    error "ambiguous service name: $service"
    exit 1
  elif [ "$#" = 0 ]; then
    error "no such service: $service"
  fi

  # try to determine the working directory of the service
  logsvcdir=`proc_cwd $1` 
  
  set -- `proc_cmdline $1`

  while [ "$#" -gt 0 ]; do
    [ -d "$logsvcdir/$1" ] && logsvcdir="$logsvcdir/$1" && break
    shift
  done

  var_dump logsvcdir

  if [ -z "$logsvcdir" ]; then
    error "cannot determine cwd of process $1"
    exit 4
  fi

  logdir="$logsvcdir"

  var_dump logdir

  if [ ! -r "$logdir/current" ]; then
    error "service $service has no log"
    exit 3
  fi

  # execute the final tail command
  exec $TAIL_cmd \
    -f "$logdir/current"
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
