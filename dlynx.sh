#!/bin/sh

while :; do
				case "$1" in
								 -p | --proxy) export http_proxy="$2"; shift 2 ;; 
				 *)break ;;
 esac
 done

: ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"}

for URL; do
  lynx -accept_all_cookies ${USER_AGENT:+-useragent="$USER_AGENT"} -dump -listonly -nonumbers -hiddenlinks=merge "$URL" 2>/dev/null
done
