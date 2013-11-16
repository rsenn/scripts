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
curl -s $ARGS "$@"
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
