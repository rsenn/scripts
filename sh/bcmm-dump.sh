#!/bin/sh
#
# -*-mode: shell-script-*-
#
# bcmm-dump.sh
#
# Copyright (c) 2008 Roman Senn,,, <enki@phalanx>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-08-12 Roman Senn,,, <enki@phalanx>
#

# set path variable defaults
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/net/www/curl.sh
. $shlibdir/data/xml.sh
. $shlibdir/std/var.sh
. $shlibdir/std/str.sh

# Main program
# --------------------------------------------------------------------------- 
main()
{
  CURL=curl
  FILE=`mktemp`

  curl_set user="adfinis" passwd="blubber42!"

  msg "temp file: $FILE"

  curl_get "https://$1/" >$FILE

  ACTION=`xml_getattribute "$FILE" FORM ACTION`

  var_dump ACTION

  case $ACTION in 
    /private/terminate_and_start_new)
     echo  curl_get $ARGS data="TIMEOUT=FF&JUNK=1" "https://$1$ACTION" #>$FILE
    ;;
  esac

}

main "$@"

#EOF
