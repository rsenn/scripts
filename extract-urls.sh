#!/bin/sh

IFS="
"

ARGS=""

if [ -e cookies.txt ]; then
  ARGS="${ARGS:+$ARGS }
--cookie
cookies.txt"
fi

extract_urls()
{
  sed \
    -e "s,%3[Aa]%2[Ff]%2[Ff],://,g" \
    | \
  sed \
    -e "s,http://,\n&,g" \
    -e "s,https://,\n&,g" \
    -e "s,ftp://,\n&,g" \
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
    case $1 in
      *://*) ( curl -s $ARGS "$1") ;;
      *) cat "$1" ;;
    esac
    shift
  done | extract_urls
fi
