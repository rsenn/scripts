#!/bin/sh
#
# -*-mode: shell-script-*-
#
# dpkg-reinstall.sh
#
# Copyright (c) 2009  <enkilo@blacksun>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2009-03-27  <enkilo@blacksun>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/data/list.sh
. $shlibdir/pkgtool/apt.sh
. $shlibdir/pkgmgr/dpkg.sh

# ---------------------------------------------------------------------------
DEFAULT_ignore="libc[6-9],lib.*gcc[1-9],libselinux[1-9]"
DEFAULT_command="aptitude reinstall"

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean help "$FLAGS_FALSE"            "show this help" h
DEFINE_boolean debug "$FLAGS_FALSE"           "enable debug mode" D
DEFINE_boolean verbose "$FLAGS_FALSE"         "verbose output" v
DEFINE_string ignore "$DEFAULT_ignore"        "comma separated list of packages to ignore" i
DEFINE_string command "$DEFAULT_command"      "command to reinstall" c
DEFINE_boolean print "$FLAGS_FALSE"           "only print the command" p
DEFINE_boolean deep "$FLAGS_FALSE"            "also reinstall all dependencies" d
DEFINE_boolean list "$FLAGS_FALSE"            "list packages only" l
DEFINE_boolean avail "$FLAGS_FALSE"           "only available packages" a

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
  IGNORE=`implode "|" $FLAGS_ignore`

  # loop through arguments
  while [ "$#" -gt 0 ]; do
    FN="$1"
    RE=`fn2re "$FN"`
    MATCH=`dpkg_match "^$RE\$"`

    if [ -z "$MATCH" ]; then
      exit 2
    fi

    if [ "$FLAGS_deep" = "$FLAGS_TRUE" ]; then
      for PKG in $MATCH; do
        pushv PKGS `apt_deps_list "$PKG"`
      done
    else
      pushv PKGS $MATCH
    fi

    shift
  done

  if [ -z "$PKGS" ]; then
    error "No package given"
    exit 1
  fi

  if [ "$FLAGS_avail" = "$FLAGS_TRUE" ]; then
    TMP="$PKGS"
    PKGS=

    for PKG in $TMP; do
      AVAIL=`apt_match -q "^$PKG\$"`
      FNAME=`apt_info $AVAIL | info_get Filename`

      if [ -z "$FNAME" ]; then
        if is-true "$FLAGS_verbose"; then
          msg "Package $PKG has no Filename"      
        fi
        unset AVAIL
      fi

      if [ -z "$AVAIL" ]; then
        warn "Package $PKG is not available!"
        continue
      fi

      if is-true "$FLAGS_debug"; then
        msg "Package $PKG Filename:" $FNAME
      fi

      pushv PKGS $AVAIL
    done
  fi

  if [ "$IGNORE" ]; then
    PKGS=`echo "$PKGS" | grep -E -v "^($IGNORE)\$"`
  fi

  if [ "$FLAGS_print" = "$FLAGS_TRUE" ]; then
    FLAGS_command="echo $FLAGS_command"
  fi

  if [ "$FLAGS_list" = "$FLAGS_TRUE" ]; then
    FLAGS_command="list"    
  fi

  # now here do something
  $FLAGS_command $PKGS
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
