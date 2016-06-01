#!/bin/sh
NL="
"
#
# -*-mode: shell-script-*-
#
# torrent-finder.sh
#
# Copyright (c) 2008 root <root@wonko01>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-08-19 root <root@wonko01>
#
set -e

# set path variable defaults
# --------------------------------------------------------------------------- 
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/std/str.sh
. $shlibdir/net/www.sh
. $shlibdir/data/xml.sh


torrent_search()
{

  if is-url "$1"; then
    url=$1
  else
    url="http://torrent-finder.com/show.php?q=$1&Browse=tabs&PageLoad=loadall&select=13"
  fi

  curl "$url" | 
  ${SED-sed} 's,<iframe,\n&,g' | xml_attrs - iframe | ${GREP-grep
-a
--line-buffered
--color=auto} 'id="sc[0-9]\+"' | 
  while read meta_result; do
    eval "$meta_result"
    echo "$src"
  done | 
  while read search; do
   msg "Fetching $search..."
   
   www_links "$search" >>/tmp/la
  done
  

}
  

# Main program
# --------------------------------------------------------------------------- 
main()
{
  while :; do
    case $1 in
      *) break ;;
    esac
    shift
  done

  torrent_search "$@"
}

main "$@"

#EOF
