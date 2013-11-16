#!/bin/bash

IFS="
"
NL="
"

ARGS=""

if [ -e cookies.txt ]; then
  ARGS="${ARGS:+$ARGS }
--cookie
cookies.txt"
fi


http_get()
{
				(set -x; curl $NO_CURLRC $VERBOSE_ARGS ${USER_AGENT+--user-agent
"$USER_AGENT"} ${PROXY+--proxy
"$PROXY"} --location -o - $ARGS "$@"
)
#wget -q -O - "$@"
}
extract_urls()
{
  sed \
    -e "s,%3[Aa]%2[Ff]%2[Ff],://,g" \
    | \
  sed \
    -e "s,http://,\n&,g" \
    -e "s,https://,\n&,g" \
    -e "s,ftp://,\n&,g" \
    -e "s|href=\\([\"']\?\\)/|href=\\1\\n$URLBASE/|g" \
    | \
  sed -n \
    -e "/^[-+0-9A-Za-z]\+:\/\// {
         s,[\"'<>{}\\\\()].*,,
         p
       }"
}

VERBOSE_ARGS="-s"
NO_CURLRC="-q"

while :; do 
				case "$1" in
								-r | --raw) RAW=true; shift ;;
								-p | --proxy) PROXY="$2"; shift 2 ;; --proxy=* | -p=*) PROXY="${1#*=}"; shift  ;; -p*) PROXY="${1#-p}"; shift  ;;
								-A | --user-agent) USER_AGENT="$2"; shift 2 ;; --user-agent=* | -A=*) USER_AGENT="${1#*=}"; shift  ;; -A*) USER_AGENT="${1#-A}"; shift  ;;
				#-q | --nocurlrc ) NO_CURLRC="-q"; shift ;; 
								-[vs] | --verbose | --silent ) VERBOSE_ARGS="$1"; shift ;;
				*) break ;;
esac
done

if [ -n "$PROXY" ] ; then
				case "$PROXY" in 
								*://*) ;;
				*) PROXY="http://$PROXY" ;;
esac

fi

read_source()
{
    case $1 in
      *://*) ( http_get "$1") ;;
      *) cat "$1" ;;
    esac \
}
CMD='read_source "$1"'
[ "$RAW" != true ] && CMD="$CMD | extract_urls"

if [ "$#" = 0 ]; then
  extract_urls
else
  while [ "$#" -gt 0 ]; do
  case "$1" in
    *://*) URL="$1" ; URLHOST=${URL#*://}; URLPROTO=${URL%%://*}; URLHOST=${URL#$URLPROTO://}; URLHOST=${URLHOST%%/*}; URLBASE="$URLPROTO://$URLHOST" ;;
    *) 
		: ${URLBASE="http://0.0.0.0"}
						URL= ;;
    esac
eval "$CMD"
    shift
  done 
fi
