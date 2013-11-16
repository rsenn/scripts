#!/bin/sh

IFS="
"

ARGS=""

if [ -e cookies.txt ]; then
  ARGS="${ARGS:+$ARGS }
--cookie
cookies.txt"
fi


http_get()
{
				(set -x; curl ${USER_AGENT+--user-agent
"$USER_AGENT"} ${PROXY+--proxy
"$PROXY"} --location -o - $ARGS "$@")
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

while :; do 
				case "$1" in
								-p | --proxy) PROXY="$2"; shift 2 ;; --proxy=* | -p=*) PROXY="${1#*=}"; shift  ;; -p*) PROXY="${1#-p}"; shift  ;;
								-A | --user-agent) USER_AGENT="$2"; shift 2 ;; --user-agent=* | -A=*) USER_AGENT="${1#*=}"; shift  ;; -A*) USER_AGENT="${1#-A}"; shift  ;;
				*) break ;;
esac
done

if [ -n "$PROXY" ] ; then
				case "$PROXY" in 
								*://*) ;;
				*) PROXY="http://$PROXY" ;;
esac

fi

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
    case $1 in
      *://*) ( http_get "$1") ;;
      *) cat "$1" ;;
    esac| extract_urls
    shift
  done 
fi
