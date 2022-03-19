#!/bin/sh
#
# -*-mode: shell-script-*-
#
# dpkg-install.sh
#
# Copyright (c) 2009  Roman Senn <roman@digitall.ch>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2009-03-27  <enkilo@blacksun>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/data/list.sh
#. $shlibdir/pkgtool/apt.sh
. $shlibdir/pkgmgr/dpkg.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags.sh

DEFINE_boolean help "$FLAGS_FALSE"            "show this help" h
#DEFINE_boolean debug "$FLAGS_FALSE"           "enable debug mode" D
#DEFINE_boolean verbose "$FLAGS_FALSE"         "verbose output" v
DEFINE_boolean hold "$FLAGS_FALSE"            "set package on hold (both in dpkg and aptitude" H

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# --------------------------------------------------------------------------- 

# Main program
# --------------------------------------------------------------------------- 
main()
{
  IFS="
, "
  PKGS=

  # loop through arguments
  while [ "$#" -gt 0 ]; do
    FN="$1"
    NAME=${FN%%_*}

   (set -e
    dpkg -i "$FN"

    if [ "$FLAGS_hold" = "$FLAGS_TRUE" ]; then
      msg "Setting package $NAME on hold..."
      dpkg --set-selections <<__EOF__
$NAME hold
__EOF__
      aptitude hold -y
    fi) || {
      error "Failed installing package $FN"
      exit 1
    }

    shift
  done
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
