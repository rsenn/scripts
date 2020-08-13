#!/bin/sh
#
# -*-mode: shell-script-*-
#
# svmigrate.sh
#
# Copyright (c) 2008 Roman Senn,,, <roman@gatling>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-10-28 Roman Senn,,, <roman@gatling>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${bindir="$shlibprefix/bin"}
: ${libdir="$shlibprefix/lib"}
: ${sysconfdir="/etc"}
: ${localstatedir="/var"}
: ${shlibdir="$libdir/sh"}
: ${servicestatedir="$localstatedir/service"}
: ${serviceconfdir="$sysconfdir/sv"}
: ${initconfdir="$sysconfdir/init.d"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh

# Main program
# --------------------------------------------------------------------------- 
main()
{
  # check whether the service state dir exists
  if [ ! -d "$servicestatedir" ]; then
    error "service state dir '$servicestatedir' doesn't exist"
  fi

  # now here do something
  for SERVICE; do

    # valid init script?
    if [ ! -e "$initconfdir/$SERVICE" ]; then
      error "No such service '$SERVICE' in '$initconfdir'"
      break
    fi

    # valid supervise directory?
    if [ ! -e "$serviceconfdir/$SERVICE" ]; then
      error "No such service '$SERVICE' in '$serviceconfdir'"
      break
    fi
      
    # check whether the service is already migrated
    INITLINK=`readlink "$initconfdir/$SERVICE"`

    if [ -L "$initconfdir/$SERVICE" -a "${INITLINK##*/}" = "sv" ]; then
      error "Service '$SERVICE' already migrated"
      continue
    fi

    # stop the unsupervised service
    "$initconfdir/$SERVICE" stop

    # activate the service
    ln -sf "$serviceconfdir/$SERVICE" "$servicestatedir/"

    # divert the old init script and replace it
    dpkg-divert "$initconfdir/$SERVICE"
    mv -f "$initconfdir/$SERVICE" "$initconfdir/$SERVICE.distrib"
    ln -sf "$bindir/sv" "$initconfdir/$SERVICE"

    # report status
    sv status "$servicestatedir/$SERVICE"

  done
  
}

# ---------------------------------------------------------------------------
main "$@"
# ---[ EOF ]-----------------------------------------------------------------

#EOF
