dump-lynx() {
 (IFS="
"
  while :; do
    case "$1" in
      -x | -debug | --debug) DEBUG=true; shift ;;
      -d | -dump | --dump)  DUMP=true; shift ;;
      -w | -wrap | --wrap)  WRAP=true; shift ;;
      -c | --config) pushv LYNX_CONFIG "$2"; shift 2 ;; -c=* | --config=*) pushv LYNX_CONFIG "${1#*=}"; shift ;; -c*) pushv LYNX_CONFIG "${1#-?}"; shift ;;
      -p | --proxy) export http_proxy="$2"; shift 2 ;; -p=* | --proxy=*) export http_proxy="${1#*=}"; shift ;; -p*) export http_proxy="${1#-?}"; shift ;;
      -C | --cookie) COOKIE_FILE="$2"; shift 2 ;; -C=* | --cookie=*) COOKIE_FILE="${1#*=}"; shift ;; -C*) COOKIE_FILE="${1#-?}"; shift ;;
      -A | --user*agent) USER_AGENT="$2"; shift 2 ;; -A=* | --user*agent=*) USER_AGENT="${1#*=}"; shift ;; -A*) USER_AGENT="${1#-?}"; shift ;;
      *) break ;;
   esac
 done

  : ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"}

  if [ "$DUMP" = true ]; then
     OPTS="-nolist"
     if [ "$WRAP" != true ]; then
       OPTS="$OPTS -width=65536"
     fi
  else
    OPTS="-listonly"
  fi

  if [ -n "$LYNX_CONFIG" ]; then
    TMPCFG=`mktemp dump-lynx-XXXXXX.cfg`
    trap 'rm -f "$TMPCFG"' EXIT
    echo "$LYNX_CONFIG" >"$TMPCFG"
    OPTS="$OPTS -cfg=\"\$TMPCFG\""
  fi

  CMD="lynx -accept_all_cookies${USER_AGENT:+ -useragent=\"\$USER_AGENT\"}${COOKIE_FILE:+ -cookie_file=\"\$COOKIE_FILE\"} $OPTS -nonumbers -hiddenlinks=merge \"\$URL\" 2>/dev/null"

  for URL; do
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD"
  done)
}
