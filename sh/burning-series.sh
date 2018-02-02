#!/bin/sh

. require.sh

require xml
require http
require url

trap 'rm -f "$DATA"' EXIT
DATA=`mktemp`

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


list_genres() {
  http_get "https://bs.to/serie-genre" >"$DATA"

  while read -r LINE; do


    case "$LINE" in
      *"<span><strong>"*) 
         STRONG=$LINE ;;
      *"</ul>"*) GENRE= ;;
      *"<ul>"*) 
        GENRE=$(value strong "$STRONG") 
        ;;
      *"<li>"*)
        if [ -n "$GENRE" ]; then
          URL=https://bs.to/$(attribute href "$LINE")
          TITLE=$(attribute title "$LINE" | url_decode_stream)
          [ -n "$TITLE" ] &&   
          printf "%-15s %-80s %s\n" "$GENRE" "$URL" "$TITLE"
        fi
      ;;
    *) : echo "$LINE" ;;
    esac
    PREV=$LINE
  done <"$DATA"
}

burning_series() {

  list_genres

}


burning_series "$@"


