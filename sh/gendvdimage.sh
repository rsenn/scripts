#!/bin/bash
#
# -*-mode: shell-script-*-
#
# gendvdimage.sh
#
# Copyright (c) 2008 Roman Senn,,, <enki@gatling>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-10-15 Roman Senn,,, <enki@gatling>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/std/str.sh

# ---------------------------------------------------------------------------
GENDVDIMAGE_system=$(str_toupper "`uname -s`")
GENDVDIMAGE_appid=${0##*/}

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean help            false                 "show this help" h
DEFINE_boolean debug           false                 "enable debug mode" D
DEFINE_string output           ""                    "output file" o
DEFINE_string volid            ""                    "volume id" v
DEFINE_string appid            "$GENDVDIMAGE_appid"  "application id" a
DEFINE_string publisher        ""                    "publisher info"
DEFINE_string preparer         ""                    "preparer info"
DEFINE_string system           "$GENDVDIMAGE_system" "operating system"
DEFINE_string sort             ""                    "list containing the sort order"
DEFINE_string hide_list        ""                    "list containing hidden files"
DEFINE_string hide_joliet_list ""                    "list containing files hidden in joliet"
DEFINE_string path_list        ""                    "list containing files"

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}


# Main program
# --------------------------------------------------------------------------- 
main()
{
  # loop through arguments
  while test "$#" -gt 0; do
    case $1 in
      --) 
        shift
        break
      ;;

      *) 
        break 
      ;;
    esac
    shift
  done

  # now here do something
  genisoimage \
    -gui \
    -graft-points \
    ${FLAGS_volid:+-volid "$FLAGS_volid"} \
    ${FLAGS_appid:+-appid "$FLAGS_appid"} \
    ${FLAGS_publisher:+-publisher "$FLAGS_publisher"} \
    ${FLAGS_preparer:+-preparer "$FLAGS_preparer"} \
    ${FLAGS_system:+-sysid "$FLAGS_system"} \
    -volset \
    ${FLAGS_sort:+-sort "$FLAGS_sort"} \
    -rational-rock \
    ${FLAGS_hide_list:+-hide-list "$FLAGS_hide_list"} \
    -joliet \
    -joliet-long \
    ${FLAGS_hide_joliet_list:+-hide-joliet-list "$FLAGS_hide_joliet_list"} \
    -no-cache-inodes \
    -full-iso9660-filenames \
    -iso-level 2 \
    ${FLAGS_path_list:+-path-list "$FLAGS_path_list"} \
    ${FLAGS_output:+-o "$FLAGS_output"} \
    "$@"

}

# ---------------------------------------------------------------------------
main "$@"
# ---[ EOF ]-----------------------------------------------------------------

#EOF
