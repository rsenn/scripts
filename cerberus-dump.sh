#!/bin/sh
#
# -*-mode: shell-script-*-
#
# cerberus-dump.sh
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
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/net/url.sh
. $shlibdir/net/www/curl.sh
. $shlibdir/data/xml.sh
. $shlibdir/data/info.sh
. $shlibdir/data/list.sh
. $shlibdir/std/var.sh
. $shlibdir/std/str.sh
. $shlibdir/std/algorithm.sh

# Parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

: ${URL="https://cerberus.adfinis.com"}

DEFINE_boolean debug  "$FLAGS_FALSE" "Debug mode"     d
DEFINE_string  url    "$URL"         "Location"       l
DEFINE_string  user   "$USER"        "HTTP username"  u
DEFINE_string  pass   "$PASS"        "HTTP password"  p

FLAGS_HELP="usage: `basename "$0"` <command> [arguments...]"

FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  : ${CURL:=curl}
 
  IFS="
" 
  # Debug mode?
  if [ "$FLAGS_debug" = "$FLAGS_TRUE" ]; then
    DEBUG="true" 
  else
    DEBUG="false"
  fi

  $DEBUG && debug "$FLAGS_debug"

  CURL_debug="$DEBUG"

    # Temp file
  LOGIN_PAGE=`mktemp`; msg "login page: $LOGIN_PAGE"

  # Do HTTP POST to the login form
  POSTDATA=`url_encode_args \
      redir="/ticket_list.php" \
      form_submit="login" \
      CER_AUTH_USER="$FLAGS_user" \
      CER_AUTH_PASS="$FLAGS_pass"
  `
  $DEBUG && msg "Post data: $*"

  curl_get >$LOGIN_PAGE "$URL/do_login.php" \
     data="$POSTDATA" \
     include="yes" \
     header="Referer: $URL/login.php"

  # Handle incoming cookies
  COOKIES=`info_get <$LOGIN_PAGE Set-Cookie | list_removesuffix ';*'`
  COOKIE=`index 1 $COOKIES`

  $DEBUG && msg "Cookie: $COOKIE"
 
  # Permanently set the Cookie header for this session 
  curl_set header="Cookie: $COOKIE"

  # Get the meta-refresh tag
  REFRESH=`xml_get <$LOGIN_PAGE meta content | list_removeprefix '*;url='`

  REPLY=`mktemp`;
  
  $DEBUG && msg "Temp file: $REPLY"
  $DEBUG && msg "Refresh:" $REFRESH

  if test -z "$REFRESH"; then
    error "Login failed!"
  fi

  curl_get include="yes" "$REFRESH" >$REPLY


  msg "Title: `xml_get <$REPLY title`"
}

main "$@"

#EOF
