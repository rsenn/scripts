#!/bin/sh
#
# -*-mode: shell-script-*-
#
# fetch-urls.sh
#
# Copyright (c) 2008 adfinis gmbh,,, <adfinis@strinder>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-08-25 adfinis gmbh,,, <adfinis@strinder>
#

# set path variable defaults
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/net/url.sh

# Main program
# --------------------------------------------------------------------------- 
main()
{

  skipchars="\\[]()*"

  mkdir -p cache

  while read url; do

   case $url in
 
     *[$skipchars]* | *://.*) continue ;;
   esac

   set -- `echo "$url" | md5sum`

   echo "$1 $url" >>processed-urls.txt

   lynx -dump -nolist -nonumbers "$url" >cache/$1

   msg "Downloaded $url"

  done <2nd-half-urls.txt  
}

main "$@"

#EOF
