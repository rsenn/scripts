#!/bin/bash

. require.sh

require url
require xml

: ${X="+x"}
#N=99 Q=`url_encode_args q="$@"`
IFS="
 "
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0"
#HTTP_PROXY="127.0.0.1:8123"

DLCMD="curl -q -s --location -A '$USER_AGENT' ${HTTP_PROXY:+--proxy \"http://${HTTP_PROXY#*://}\"}"

#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }wget -q -O - -U '$USER_AGENT'"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" https_proxy=\"http://${HTTP_PROXY#*://}\" }lynx -source -useragent '$USER_AGENT' 2>/dev/null"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }links -source"
##DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }w3m -dump_source 2>/dev/null"


q()
{
  if [ $# -gt 1 ]; then
    Q="{$(implode , "$@")}"
  else
    Q="$1"
  fi
}

implode()
{
  (S="$1"
   shift
   unset O
   while [ $# -gt 0 ]; do
     O="${O+$O$S}$1"
     shift
   done
   echo "$O")
}

rpmfind()
{
  q "$@"
  FILTERCMD="sed \"s|<a|\n&|g\" | grep '</td></tr>'  | xml_get a href"
  SEARCHCMD="$DLCMD \"http://rpmfind.net/linux/rpm2html/search.php?query=\"${Q}\"&submit=Search+...&system=&arch=\" | $FILTERCMD"
  eval "$SEARCHCMD"
}

rpmseek()
{
  URL="http://search.rpmseek.com"
  q "$@"
  FILTERCMD="sed 's|<a|\n&|g' | grep -i -E  '^<a.*(span class=\"suchergebnis\"|?hl=com.*PN)'  | xml_get a href | sed \"s|^?|/search.html&| ;; s|^/|\$URL/|\""
  SEARCHCMD="$DLCMD \"\$URL/search.html?hl=com&cs=\"$Q\":PN:0:0:1:0:0\" | $FILTERCMD"
  eval "$SEARCHCMD"
}


pbone()
{
  URL="http://rpm.pbone.net"
  q "$@"
  FILTERCMD="sed 's|<a|\n&|g' | sed 's|<A|\n&|g' | grep -i -E '(</TD></TR>|search=)' | xml_get '[Aa]' '[Hh][Rr][Ee][Ff]' | sed \"s|^/|\$URL/|\""
  SEARCHCMD="$DLCMD \"\$URL/index.php3?stat=3&search=\"${Q}\"&Search.x=0&Search.y=0&simple=1&srodzaj=4\" | $FILTERCMD"
  eval "$SEARCHCMD"
}

SEARCH_ENGINES="rpmfind rpmseek pbone"

for ENGINE in $SEARCH_ENGINES; do
  echo "Searching with '$ENGINE'..." 1>&2
  $ENGINE "$@"
done
