#!/bin/sh

: ${TEMP=/tmp}

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

while :; do
  case "$1" in
    -x|--debug) DEBUG=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -s=*|--save*=*) SAVE_TMP=${1#*=}; shift ;;
    -s|--save*) SAVE_TMP=$TEMP/`basename "${0%.sh}"`$$.txt; echo -n >"$SAVE_TMP" ; shift ;;
    -t=*|--type=*) TYPE=${1%#*=}; shift ;; -t|--type) TYPE=$2; shift 2 ;;
    -c=*|--class=*) CLASS=${1%#*=}; shift ;; -c|--class) CLASS=$2; shift 2 ;;
    -n=*|--results=*) RESULTS=${1%#*=}; shift ;; -n|--results) RESULTS=$2; shift 2 ;;
    -*) echo "Invalid argument '$1'." 1>&2; exit 1 ;;
    *) break ;;
  esac
done

: ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0"}
: ${RESULTS=30}
#http_proxy="127.0.0.1:8123"

[ "$VERBOSE" = true ] || SILENT="-s"
for COOKIE in $(ls -td -- {,"$HOME"/,"$TEMP"/,"$TEMPDIR"/,"$TMP"/}{cookie.txt,cookies.txt} 2>/dev/null); do
  [ -s "$COOKIE" ]  && { echo "Found cookie: $COOKIE" 1>&2; break; } || unset COOKIE
done
if [ -n "$http_proxy" ]; then
  echo "Have HTTP proxy: $http_proxy" 1>&2
fi
if [ -n "$socks_proxy" ]; then
  echo "Have SOCKS proxy: $socks_proxy" 1>&2
fi
DLCMD="curl ${SILENT} ${COOKIE:+--cookie '$COOKIE'} --insecure --location ${http_proxy:+--proxy \"http://${http_proxy#*://}\"} ${socks_proxy:+--socks4a \"${socks_proxy#*://}\"} -A '$USER_AGENT'"

[ "$DEBUG" = true ] && echo "DLCMD=$DLCMD" 1>&2
#DLCMD="${http_proxy:+http_proxy=\"http://${http_proxy#*://}\" }wget -q -O - -U '$USER_AGENT'"
#DLCMD="${http_proxy:+http_proxy=\"http://${http_proxy#*://}\" https_proxy=\"http://${http_proxy#*://}\" }lynx -source -useragent '$USER_AGENT' 2>/dev/null"
#DLCMD="${http_proxy:+http_proxy=\"http://${http_proxy#*://}\" }links -source"
#DLCMD="${http_proxy:+http_proxy=\"http://${http_proxy#*://}\" }w3m -dump_source 2>/dev/null"

ARGS="$*"

set -- 
for ARG in $ARGS; do
  #echo "ARG is $ARG" 1>&2
  set -- "$@" `urlescape "$ARG"`
  #echo "@ is $@" 1>&2
done

IFS="+$IFS"
#URL=`surfraw -p -escape-url-args="no" google -results="${RESULTS-30}" "$*"`


if [ "$RESULTS" -le 100 ]; then
  END=0
else
  END="$RESULTS"
  RESULTS=100
fi


case "$CLASS" in
  image*|img*) 
    URLS="http://www.google.com/search?safe=off&site=imghp&tbs=isz:ex${TYPE+%2Cift:$TYPE}&tbm=isch&source=hp&biw=1280&bih=823&q=$*&oq=$*&num=${RESULTS-30}"
    FILTER="sed -n 's,.*imgrefurl=\\([^&]\+\\).*imgurl=\\([^&]\+\\).*,\\2,p'"
  ;;
  *) URLS="http://www.google.com/search?q=$*&num=${RESULTS-30}" ;;
esac

I="$RESULTS"
while [ "$I" -lt "$END" ]; do
  URLS="${URLS:+$URLS
}http://www.google.com/search?q=$*&num=${RESULTS}&start=$I"
  I=$((I + RESULTS))
done

#echo "URL is $URL" 1>&2
CMD="$DLCMD \$URLS"

if [ -n "$SAVE_TMP" ]; then
  CMD="$CMD | { tee -a \"\$SAVE_TMP\"; echo \"Temporary data saved as \$SAVE_TMP\" 1>&2; }"
fi

[ "$DEBUG" = true ] && CMD="set -x; $CMD"

FILTER="sed 's%<%\n&%g' | sed -n 's%^<a href=\"\\([^\"/:]\\+://[^\"]\\+\\)\"[^>]\\+.*%\\1%p'${FILTER:+ | $FILTER}"
FILTER="$FILTER | sed 's%\\&amp;%\\&%g'"
eval "($CMD) ${FILTER:+ | ${FILTER#\ \|\ }}" 