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


http_get() {
 (case "$METHOD" in
	curl)  CMD='curl $NO_CURLRC $VERBOSE_ARGS ${COOKIE:+--cookie'${NL}'"$COOKIE"} ${USER_AGENT+--user-agent'${NL}'"$USER_AGENT"}  ${HTTP_PROXY:+--proxy'${NL}'"http://${HTTP_PROXY#*://}"} ${SOCKS_PROXY:+--socks4a'${NL}'"${SOCKS_PROXY#*://}"}  --location -o - $ARGS "$@"' ;;
	wget) CMD=${PROXY+'http_proxy="$PROXY" '}'wget -q  ${COOKIE:+--load-cookies="$COOKIE"} ${USER_AGENT+-U'${NL}'"$USER_AGENT"} --content-disposition -O - $ARGS "$@"' ;;
	lynx) CMD=${PROXY+'http_proxy="$PROXY" '}'lynx -source  ${COOKIE:+-cookie_file="$COOKIE"} ${USER_AGENT+-useragent="$USER_AGENT"} $ARGS "$@" 2>/dev/null' ;;
	w3m) CMD=${PROXY+'http_proxy="$PROXY" '}${USER_AGENT+'user_agent="$USER_AGENT" '}'w3m -dump_source $ARGS "$@" 2>/dev/null | zcat -f' ;;
	links) CMD='links  -source  ${PROXY+-${PROXY%%://*}-proxy'${NL}'"${PROXY#*://}"} ${USER_AGENT+-http.fake-user-agent'${NL}'"$USER_AGENT"}   $ARGS "$@" |zcat -f' ;;
  esac
  eval ": set -x; $CMD")
#wget -q -O - "$@"
}
extract_urls()
{
  sed \
    -e "s,%3[Aa]%2[Ff]%2[Ff],://,g" \
    | \
  sed \
    -e "s,\([^a-z]\)\([a-z]\+\)://,\1\n\2://,g" \
    -e "s,http://,\n&,g" \
    -e "s,https://,\n&,g" \
    -e "s,ftp://,\n&,g" \
    -e "s,git[^:]*://,\n&,g" \
    -e "s|href=\\([\"']\?\\)/|href=\\1\\n$URLBASE/|g" \
    | \
  sed -n \
    -e "/^[-+0-9A-Za-z]\+:\/\// {
         s,[\"'<>{}\\\\()].*,,
         p
       }"
}

main() {
  VERBOSE_ARGS="-s"
  NO_CURLRC="-q"
  METHOD="curl" 

  while :; do 
	case "$1" in
			-r | --raw) RAW=true; shift ;;
			-m | --method) METHOD="$2"; shift 2 ;; --method=* | -m=*) METHOD="${1#*=}"; shift  ;; -m*) METHOD="${1#-m}"; shift  ;;
			-p | --proxy) PROXY="$2"; shift 2 ;; --proxy=* | -p=*) PROXY="${1#*=}"; shift  ;; -p*) PROXY="${1#-p}"; shift  ;;
			-A | --user-agent) USER_AGENT="$2"; shift 2 ;; --user-agent=* | -A=*) USER_AGENT="${1#*=}"; shift  ;; -A*) USER_AGENT="${1#-A}"; shift  ;;
	#-q | --nocurlrc ) NO_CURLRC="-q"; shift ;; 
			-[vs] | --verbose | --silent ) VERBOSE_ARGS="$1"; shift ;;
	*) break ;;
  esac
  done

  case "$USER_AGENT" in
	*|-|""|x|.) USER_AGENT="Mozilla/5.0 (Windows NT 5.1; rv:21.0) Gecko/20100101 Firefox/21.0 SeaMonkey/2.18" ;;
  esac

	if [ -z "$COOKIE" ]; then
	  for COOKIE in $(ls -td -- {,"$HOME"/,"$TEMP"/,"$TEMPDIR"/,"$TMP"/}{cookie.txt,cookies.txt} 2>/dev/null); do
		[ -s "$COOKIE" ]  && break || unset COOKIE
	  done
	fi

	if [ -n "$COOKIE" -a -r "$COOKIE" -a -s "$COOKIE" ]; then
	echo "Found cookie: $COOKIE" 1>&2
	fi

  if [ -n "$PROXY" ] ; then
	case "$PROXY" in 
	  *://*) ;;
	  *) PROXY="http://$PROXY" ;;
	esac
  fi
  
	

  if [ -n "$HTTP_PROXY" ]; then
	echo "Have HTTP proxy: $HTTP_PROXY" 1>&2
  fi
  if [ -n "$SOCKS_PROXY" ]; then
	echo "Have SOCKS proxy: $SOCKS_PROXY" 1>&2
  fi

  read_source() {
	  case $1 in
		*://*) ( http_get "$1") ;;
		-) ( while read -r LINE; do
				http_get "$LINE"; done ) ;;
		*) cat "$1" ;;
	  esac 
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
}

main "$@"
