#!/bin/sh

urlescape()
{
  echo "$1" | 
    sed \
      -e 's,",%22,g' \
      -e 's,+,%2B,g' \
      -e 's,|,%7C,g' \
      -e 's,",%22,g' \
      -e 's,/,%2F,g' \
      -e 's, ,%20,g'
}

IFS="
"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0"
#HTTP_PROXY="127.0.0.1:8123"

DLCMD="curl -s --insecure --location -A '$USER_AGENT' ${HTTP_PROXY:+--proxy \"http://${HTTP_PROXY#*://}\"} ${SOCKS_PROXY:+--socks5 \"${SOCKS_PROXY#*://}\"}"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }wget -q -O - -U '$USER_AGENT'"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" https_proxy=\"http://${HTTP_PROXY#*://}\" }lynx -source -useragent '$USER_AGENT' 2>/dev/null"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }links -source"
#DLCMD="${HTTP_PROXY:+http_proxy=\"http://${HTTP_PROXY#*://}\" }w3m -dump_source 2>/dev/null"

ARGS="$*"

set -- 
for ARG in $ARGS; do
  #echo "ARG is $ARG" 1>&2
  set -- "$@" `urlescape "$ARG"`
  #echo "@ is $@" 1>&2
done

IFS="+$IFS"
#URL=`surfraw -p -escape-url-args="no" google -results="${RESULTS-30}" "$*"`

if [ -z "$RESULTS" ]; then
  RESULTS=30
fi

if [ "$RESULTS" -le 100 ]; then
  END=0
else
  END="$RESULTS"
  RESULTS=100
fi


URLS="http://www.google.com/search?q=$*&num=${RESULTS-30}"
I="$RESULTS"
while [ "$I" -lt "$END" ]; do
  URLS="${URLS:+$URLS
}http://www.google.com/search?q=$*&num=${RESULTS}&start=$I"
  I=$((I + RESULTS))
done

#echo "URL is $URL" 1>&2

eval "(set -x; $DLCMD \$URLS)"  |
sed 's,<,\n&,g'| sed -n 's,^<a href="\([^"/:]\+://[^"]\+\)"[^>]\+.*,\1,p'
