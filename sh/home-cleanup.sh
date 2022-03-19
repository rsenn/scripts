#!/bin/sh
#
# -*-mode: shell-script-*-
#
# home-cleanup.sh
#
# Copyright (c) 2008 Roman Senn <rs@adfinis.com>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-10-02 Roman Senn <rs@adfinis.com>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/fs/dir.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags.sh

DEFINE_boolean  help  "$FLAGS_FALSE"  "show this help" h
DEFINE_boolean  debug "$FLAGS_FALSE"  "enable debug mode" D
DEFINE_string   dir   "unsorted"      "messie directory" d
DEFINE_boolean  here  "$FLAGS_FALSE"  "in current directory"

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  if [ "$FLAGS_here" != "$FLAGS_TRUE" ]; then
    msg "Entering $HOME"

    cd "$HOME"
  fi

  mkdir -p "${FLAGS_dir=unsorted}"

  find * \
     -maxdepth 0 \
      -type f \
      -not -name ".*" | 
  {
    while read file; do
      mv -vf "$file" "$FLAGS_dir"
    done
  }
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
