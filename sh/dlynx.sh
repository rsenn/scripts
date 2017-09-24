#!/bin/sh

push() { 
 eval "shift;$1=\"\${$1+\"\$$1 \"}\$*\""
}
usage() {
 echo "Usage: $(basename "$0" .sh) [options] <urls...>
 
 -d, -dump, --dump   Output page content
 " 1>&2
 }

if [ -s ~/cookies.txt ]; then
				echo "Found ~/cookies.txt" 1>&2
				COOKIES=~/cookies.txt
fi

while :; do
  case "$1" in
    -np | -no*parent | --no*parent)  NO_PARENT=true; shift ;; 
    -d | -dump | --dump)  DUMP=true; shift ;; 
    -s | -source | --source)  SOURCE=true; shift ;; 
    -c | -cookie | --cookies)  COOKIES="$2"; shift 2;; 
    -c=* | -cookie=* | --cookies=*)  COOKIES="${1#*=}"; shift ;; -c*) COOKIES="${1#-?}"; shift ;;
    -x | -debug | --debug)  DEBUG=true; shift ;; 
    -p | --proxy) export http_proxy="$2"; shift 2 ;; 
    -h | -help | --help) usage; exit 1 ;; 
    *) break ;;
 esac
 done

#: ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"}
: ${USER_AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36"}
  CMD="lynx -accept_all_cookies${USER_AGENT:+ -useragent=\"\$USER_AGENT\"}${COOKIES:+ -cookie_file=\"\$COOKIES\"} \$OPTS \"\$URL\" 2>/dev/null"

[ "$SOURCE" = true ] || { [ "$DUMP" != true ] && { DUMP=true; WIDTH=16384; }; }

if [ "$SOURCE" != true -a "$DUMP" != true ]; then
	CMD="$CMD | grep '^[^ \\t]*://'"
fi

[ "$DUMP" = true ] && { WIDTH=16384; push OPTS -dump -nonumbers; } || push OPTS -listonly
[ -n "$WIDTH" ] && push OPTS -width="$WIDTH"
[ "$SOURCE" = true ] && { push OPTS -source; DUMP="false" ; }

#[ -n "$COOKIES" ] || OPTS="-cookie_file=\"\$COOKIES\""

: ${OPTS:="-dump -nonumbers -hiddenlinks=merge"}

  [ "$NO_PARENT" = true ] && CMD="$CMD | grep \"\${URL%/}/[^?]\""

	[ "$DEBUG" = true ] && CMD="(set -x; $CMD)"
  CMD="for URL; do $CMD; done"
  eval "$CMD"
