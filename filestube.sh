#!/bin/bash

. require.sh

require url

case "$1" in
  -x) X="-x"; shift ;;
esac

: ${X="+x"}
N=99
Q=`url_encode_args q="$@"`
IFS="
 "
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0"
#SOCKS_PROXY="127.0.0.1:8123"

DLCMD="curl -q -s --location -A '$USER_AGENT' ${HTTP_PROXY:+--proxy \"http://${HTTP_PROXY#*://}\"} ${SOCKS_PROXY:+--socks5 \"${SOCKS_PROXY#*://}\"}"
#DLCMD="${SOCKS_PROXY:+http_proxy=\"http://${SOCKS_PROXY#*://}\" }wget -q -O - -U '$USER_AGENT'"
#DLCMD="${SOCKS_PROXY:+http_proxy=\"http://${SOCKS_PROXY#*://}\" https_proxy=\"http://${SOCKS_PROXY#*://}\" }lynx -source -useragent '$USER_AGENT' 2>/dev/null"
#DLCMD="${SOCKS_PROXY:+http_proxy=\"http://${SOCKS_PROXY#*://}\" }links -source"
#DLCMD="${SOCKS_PROXY:+http_proxy=\"http://${SOCKS_PROXY#*://}\" }w3m -dump_source 2>/dev/null"

SEQ=$(set -- `seq -s , 1 $N`; IFS=","; echo "${*%,}")
#echo "CMD='$CMD' SEQ='$SEQ'" 1>&2

#CMD="$DLCMD \"http://www.filestube.com/look_for.html?${Q}&select=All&Submit=Search&${HOSTING:+hosting=${HOSTING}&}page=\"{$SEQ}"
CMD="$DLCMD \"http://www.filestube.to/query.html?${Q}&select=All&Submit=Search&${HOSTING:+hosting=${HOSTING}&}page=\"{$SEQ}"

[ "${X:--x}" = -x ] && echo "+ $CMD" 1>&2; eval "$CMD"|
sed 's,<,\n<,g' | 
sed -n "/resultsLink/ s,.*href=\"\\([^\"]*\\)\".*,http://www.filestube.com\\1,p" |
while read -r LINK; do
#				echo "LINK=$LINK" 1>&2
    (   CMD="$DLCMD '$LINK'"; [ "${X:--x}" = -x ] && echo "+ $CMD" 1>&2; eval "$CMD")  | 
		sed "s|>\s*<|>\n<|g" |
		sed -n '\|<pre| { :lp; N; \|</pre|! b lp; p; }' |
		sed "s|</\?pre[^>]*>||g"

done | sed -u '/^\s*$/d'
