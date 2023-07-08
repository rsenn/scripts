#!/bin/bash

. require.sh

require html
require xml
require http
require url
#require util
require var

[ -z "$DEBUG" ] && trap 'rm -f "$DATA"' EXIT
DATA=$(mktemp)
COLS=$(tput cols)
: ${COLS:=$COLUMNS}
: ${COLS:=80}

value() {
  TAG=$1
  shift
  case "$*" in
  *"<$TAG>"*"</$TAG>"*)
    TEXT=${*#*"<$TAG>"}
    [ "$TEXT" = "$*" ] && TEXT=${*#*"<$TAG "*">"}
    TEXT=${TEXT%%"</$TAG>"*}
    echo "$TEXT"
    ;;
  esac
}

attribute() {
  NAME=$1
  shift
  case "$*" in
  *" $NAME=\""*)
    VALUE=${*#*" $NAME=\""}
    VALUE=${VALUE%%\"*}
    echo "$VALUE"
    ;;
  esac
}

shell_dequote() {
  T=${*//"&#039;"/"'"}
  T=${*//"&shell_quote;"/"\""}
  T=${T//"&amp;"/"&"}
  echo "$T"
}

search_modules() {
  #var_dump URL 1>&2
  http_get "$URL" | sed '\|<section.*package/| { s|<section|\n&|g; } ;; \|<a href="/search.*page=| { s|<a href="/search.*page=|\n&|g; }' >"$DATA"

  #grep '.*' -H "$DATA"

  case "$URL" in
  *page=*)
    THIS_PAGE=${URL#*page=}
    THIS_PAGE=${THIS_PAGE%%"&"*}
    ;;
  *)
    THIS_PAGE=0
    ;;
  esac

  echo "$URL
"
  while read -r LINE; do

    case "$LINE" in
    "<section"*)
      HREF=https://www.npmjs.com$(echo "$LINE" | xml_get a href | head -n1)
      TEXT=$(echo "$LINE" | sed 's|<[^a][^>]*>| |g ; s|\s\+| |g')

      case "$TEXT" in
      *\ ago\<*)
        AGO=${TEXT%%" ago</"*}
        AGO=${AGO##*>}
        AGO=${AGO#*"•"}
        ;;
      *)
        AGO=
        ;;
      esac

      #echo "$AGO" >"text.txt"; grep '.*' -H text.txt
      DESC=$(echo "$TEXT" | sed 's|.*Description\s\([^<]*\)<.*|\1|')
      DESC=${DESC%Keywords }
      DESC=${DESC%Keywords}
      DESC=${DESC%Publisher }
      DESC=${DESC%Publisher}

      #DESC=$(echo "$DESC" | html_text )
      if [ "$HREF" -a "$DESC" ]; then
        I=$((I + 1))
        printf "%-40s %-20s %s\n" "${HREF#*/package/}" "$AGO" "${DESC:0:$((COLS - 62))}"
      fi
      #var_dump  HREF DESC 1>&2
      ;;
      #*"<span><strong>"*)
      #   STRONG=$LINE ;;
      #*"</ul>"*) GENRE= ;;
      #*"<ul>"*)
      #  GENRE=$(value strong "$STRONG")
      #  ;;
      #*"<li>"*)
      #  if [ -n "$GENRE" ]; then
    #    URL=https://bs.to/$(attribute href "$LINE")
    #    TITLE=$(attribute title "$LINE")
    #    [ -n "$TITLE" ] &&
    #      printf "%-15s %-80s %s\n" "$GENRE" "$URL" "$(shell_dequote "$TITLE")"
    #  fi
    #;;
    *page=*)
      PAGES=$(echo "$LINE" | xml_get a href | sed -n '/page=/ { s|&amp;|\&|g; s|^|https://www.npmjs.com|; p }' | sort -t= -k3 -n)
      if [ -z "$LAST_PAGE" ]; then
        LAST_PAGE=$(
          set -- $PAGES
          eval echo "\${$#}"
        )
        LAST_PAGE=${LAST_PAGE#*page=}
        LAST_PAGE=${LAST_PAGE%%"&"*}
        echo "Last page:" $PAGES
      fi
      #var_dump PAGES LAST_PAGE 1>&2
      ;;
    *) : echo "$LINE" ;;
    esac
    PREV=$LINE
  done <"$DATA"
  echo

  set -- $PAGES
  while [ $# -gt 0 ]; do
    case "$1" in
    *page=$((THIS_PAGE + 1))*)
      NEXT_PAGE="$1"
      break
      ;;
    esac
    shift
  done

  [ -n "$DEBUG" ] && var_dump THIS_PAGE NEXT_PAGE LAST_PAGE 1>&2
}

npmjs() {

  while :; do
    case "$1" in
    -n | -num | --num)
      N=$2
      shift 2
      ;;
    *) break ;;
    esac
  done

  [ -n "$DEBUG" ] && exec 1>&2
  old_IFS="$IFS"
  IFS=" "
  Q="$*"
  IFS="$old_IFS"
  I=0
  P=0
  #: ${N:=30}
  URL="https://www.npmjs.com/search?$(url_encode_args q="$Q")"

  while [ -n "$URL" -a "${THIS_PAGE:-0}" != "$LAST_PAGE" ${N:+-a
$I
-lt
$N} ]; do

    search_modules | sed 's|\s*<[^>]*>\s*||g'
    [ -n "$DEBUG" ] && var_dump NEXT_PAGE 1>&2

    URL=$NEXT_PAGE

  done

  [ -n "$DEBUG" ] && echo "$DATA"

}

npmjs "$@"
