#!/bin/sh
NL="
"
#
# -*-mode: shell-script-*-
#
# download-files.sh
#
# Copyright (c) 2008  <enki@vinylz>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-11-20  <enki@vinylz>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/data/xml.sh
#. $shlibdir/buildsys.sh

. shflags.sh

# default configuration
# ---------------------------------------------------------------------------
DEFAULT_extensions="7z bz2 exe gz msi pdf rar tar tar\\.gz tar\\.bz2 tbz2 tgz zip mp3 ogg wav mp4 avi mpg mpeg mkv bin ttf otf pcf fon txt"
DEFAULT_useragent="Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)"
DEFAULT_secure="$FLAGS_FALSE"
DEFAULT_client="wget"

# parse command line options using shflags 
# ---------------------------------------------------------------------------
DEFINE_boolean help          "$FLAGS_FALSE" "show this help" h
DEFINE_boolean debug         "$FLAGS_FALSE" "enable debug mode" D
DEFINE_string  inputfile     "-"         "input file" i
#DEFINE_string  shlibprefix        ""          "install architecture-independent files in PREFIX"
#DEFINE_string  sysconfdir    ""          "read-only single-machine data [PREFIX/etc]"
#DEFINE_string  localstatedir ""          "modifiable single-machine data [PREFIX/var]"
#DEFINE_string  host          ""          "cross-compile to build programs to run on HOST [BUILD]"
#DEFINE_string  build         ""          "configure for building on BUILD [guessed]"
#DEFINE_string  target        ""          "configure for building compilers for TARGET [HOST]"
DEFINE_string  extensions    "$DEFAULT_extensions" "file name extensions accepted" e
DEFINE_string  addext        ""                    "additional extensions accepted" x
DEFINE_string  useragent     "$DEFAULT_useragent"  "browser user-agent" a
DEFINE_boolean secure        "$DEFAULT_secure"     "check certificate" s   
DEFINE_string  client        "$DEFAULT_client"     "client used to download" c
DEFINE_boolean print_urls    "$FLAGS_FALSE"      "print URLs instead of downloading" p

FLAGS_HELP="usage: `basename "$0"` [flags] <url>
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# svnbuild_usage
# ---------------------------------------------------------------------------                                                  
svnbuild_usage()
{
  flags_help
}

# command lines
ARIA_OPTS="-c
--ftp-pasv
--parameterized-uri=true
--allow-overwrite=true
--auto-file-renaming=false
--log-level=info"
WGET_OPTS="-c
--content-disposition" 
COMMON_OPTS="${FLAGS_useragent:+--user-agent=$FLAGS_useragent}"

if [ "$DEFAULT_secure" = no ]; then
  ARIA_OPTS="$ARIA_OPTS
-check-certificate=false"
  WGET=_OPTS="$WGET_OPTS
--no-check-certificate"
fi

IFS="
$IFS"
URLS="$*"

# process file extension list
IFS_save="$IFS"
IFS="|¦;,/$IFS"

set -- $FLAGS_extensions $FLAGS_addext

EXTLIST="$*"
IFS="$IFS_save"
COOKIEFILE=`mktemp cookie.XXXXXX`
HEADERFILE=`mktemp header.XXXXXX`
DATAFILE=`mktemp data.XXXXXX`

trap ': ${GREP-grep
-a
--line-buffered
--color=auto} --color -H ".*" "$COOKIEFILE"; rm -f "$COOKIEFILE"
: ${GREP-grep
-a
--line-buffered
--color=auto} --color -H ".*" "$HEADERFILE"; rm -f "$HEADERFILE"
: echo "Data: $DATAFILE"' EXIT

# read cookies from cURL
readcookies()
{
#  echo "Filtering for $EXTLIST ..." 1>&2
#  ${GREP-grep
-a
--line-buffered
--color=auto} -E -i "\.($EXTLIST)\$" |
#  while read FILE; do
#    echo "Got file $FILE ." 1>&2
#    echo "$FILE"
#  done
#} |
#case $FLAGS_client in
#  aria*) aria2c $ARIA_OPTS $COMMON_OPTS -Z -i - ;;
#  wget) wget $WGET_OPTS $COMMON_OPTS -i - ;;
#esac
  local IFS_save="$IFS"
  unset COOKIES
  IFS="	""
 "
  while read DOMAIN FLAG LOCATION FLAG2 EXPIRES NAME VALUE; do
    case $DOMAIN:$NAME=$VALUE in
      "#"*:*:* | *:"":"") ;;
      .*:*:*) COOKIES="${COOKIES+$COOKIES; }$NAME=$VALUE" ;;
    esac
  done
  IFS="$IFS_save"
}

for URL in $URLS; do 
  case $URL in
    ftp://*)
      lynx -dump -accept_all_cookies \
        -stderr -tlog -trace 2>>lynx.log \
        ${FLAGS_useragent:+-useragent="$FLAGS_useragent"} \
        `[ -s "$COOKIEFILE" ] && echo -cookie_file="$COOKIEFILE"` \
        -cookie_save_file="$COOKIEFILE" "$URL" |
      ${SED-sed} -n "/^ *[0-9]\\+\\. / s/^ *[0-9]\\+\\. //p"
    ;;
    *)
     (#set -x
      curl -s \
         --insecure --location --ftp-pasv \
         --dump-header "$HEADERFILE" \
         --cookie-jar "$COOKIEFILE" \
         `[ -s "$COOKIEFILE" ] && echo --cookie="$COOKIEFILE"`  \
         ${FLAGS_useragent:+"-A=$FLAGS_useragent"} \
         "$URL")  | #tee "$DATAFILE" |
        xml_get a href |
        while read FILE; do
          case $FILE in
            */*) ;;
            *) FILE="${URL%/*}/$FILE" ;;
          esac
          echo "$FILE"
        done
        #${SED-sed} -e 's,[-+a-z]\+://,\n&,g' | ${GREP-grep
-a
--line-buffered
--color=auto} '^[-+a-z]*://' | ${SED-sed} -e 's,[ ">].*,,' 
    ;;
  esac |  #|
 (grep -E -i "\.($EXTLIST)\$") |
 (while read FILE; do
    #echo "Downloading \"$FILE\"..." 1>&2
    case $FLAGS_client:$FLAGS_print_urls in
      aria*:$FLAGS_FALSE) echo "$FILE
  out=${FILE##*[/=]}" ;;
      *) echo "$FILE" ;;
    esac
  done) |
 (IFS="
";
  COMMON_OPTS="$COMMON_OPTS
--referer=$URL"

  #while [ ! -s "$COOKIEFILE" ]; do 
  #  sleep 0.1
  #done
  sleep 0.5

  readcookies <$COOKIEFILE

  for COOKIE in $COOKIES; do
    COMMON_OPTS="$COMMON_OPTS
--header=Cookie: $COOKIE"
  done
  
  if [ "$FLAGS_print_urls" = "$FLAGS_TRUE" ]; then
    while read URL; do
      echo "$URL"
    done
  else
#    set -x
    case $FLAGS_client in
      aria*) aria2c $ARIA_OPTS $COMMON_OPTS -Z -i - ;;
      wget) wget --input-file - $WGET_OPTS $COMMON_OPTS ;;
    esac
  fi)
done
