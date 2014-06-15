#!/bin/sh
#
# -*-mode: shell-script-*-
#
# download-latest.sh
#
# Copyright (c) 2009 enki,,, <enkilo@gatling-eth>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2009-03-30 enki,,, <enkilo@gatling-eth>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
#. $shlibdir/util.sh
#. $shlibdir/net/www.sh
#. $shlibdir/net/www/curl.sh
. $shlibdir/data/xml.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean  help         "$FLAGS_FALSE"     "show this help"            h
DEFINE_boolean  debug        "$FLAGS_FALSE"     "enable debug mode"         D
DEFINE_string   dryrun       "$FLAGS_FALSE"     "don't download, only list" n
DEFINE_boolean  print_urls   "$FLAGS_FALSE"     "print instead of downloading" p
DEFINE_integer  every_nth     10                "print status message every Nth URL" c

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# Get links
# ---------------------------------------------------------------------------
getlinks()
{
  #wget -nv -O - "$@" | xml_get "[Aa]" "[Hh][Rr][Ee][Ff]"
  wget -nv -O - "$@" | xml_get a href
}

# ---------------------------------------------------------------------------
reduceversion()
{
 (EXPR='s,\([-\._]\?\)[0-9]\+\([-_\.][0-9]\+\)*[a-z]\?,\1{},g'

  case "${1+set}" in
    set) echo "$1" | sed -e "$EXPR" ;;
    "") sed -e "$EXPR" ;;
  esac)
}

# ---------------------------------------------------------------------------
filterlatest()
{
 (IFS="
 "
  PREVBASE= PREVURL= PREVMASK=

  while read MASK BASE URL; do
    if [ -n "$PREVURL" -a "$MASK" != "$PREVMASK" ]; then
      echo "$PREVURL"
    fi
 
    PREVMASK="$MASK" PREVBASE="$BASE" PREVURL="$URL"
  done)
}

# ---------------------------------------------------------------------------
processlist()
{
  { while read URL; do
      BASE=${URL##*/}
      MASK=`reduceversion "$BASE"`

      echo "$MASK $BASE $URL"
      #echo "$MASK $BASE $URL" 1>&2 
    done
    echo
  } | sort -V -k1,2 | filterlatest
  #case $FLAGS_print in $FLAGS_TRUE) filterlatest ;; $FLAGS_FALSE) filterlatest | wget -c --passive-ftp -i - ;; esac 
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  # now here do something
  case "${1+set}" in
    set) getlinks "$@" | processlist ;;
    *) processlist ;;
  esac
}

# ---------------------------------------------------------------------------

main "$@"
# ---[ EOF ]-----------------------------------------------------------------

#EOF
