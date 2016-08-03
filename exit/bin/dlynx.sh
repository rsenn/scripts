#!/bin/sh

while :; do
  case "$1" in
    -np | -no*parent | --no*parent)  NO_PARENT=true; shift ;; 
    -d | -dump | --dump)  DUMP=true; shift ;; 
    -p | --proxy) export http_proxy="$2"; shift 2 ;; 
    *) break ;;
 esac
 done

: ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"}

[ "$DUMP" = true ] || OPTS="-listonly"

  CMD="lynx -accept_all_cookies${USER_AGENT:+ -useragent=\"\$USER_AGENT\"} -dump $OPTS -nonumbers -hiddenlinks=merge \"\$URL\" 2>/dev/null"
  [ "$NO_PARENT" = true ] && CMD="$CMD | grep \"\${URL%/}/[^?]\""

  CMD="for URL; do $CMD; done"
  eval "$CMD"