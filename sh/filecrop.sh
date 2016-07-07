#!/bin/bash


. require.sh

require url
require xml

xargs()
{
  (echo "xargs:" "$@" 1>&2
while :; do
    case "$1" in
      -n=*) N=${1#*=}; shift ;;
      -n) N=${2}; shift 2 ;;
      -n*) N=${1#-?}; shift ;;
      -d=*) D=${1#*=}; shift ;;
      -d) D=${2}; shift 2 ;;
      -d*) D=${1#-?}; shift ;;
       *) break ;;
    esac
   done

   IFS="$D"; while read -r LINE; do
 #echo "LINE=$LINE" 1>&2 
     (IFS="
" 
set ${DEBUG:--x}; 
      "$@" $LINE)
   done)
}

ME=`basename "${0}" .sh`
COOKIES="${ME}.cookies"
: ${DEBUG:="-x"}
: ${VERBOSE:="-s"}
: ${USER_AGENT:='Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11'}
N=99
NL="
"
IFS="- "
set -- $*
A=${*}
IFS="
 "
URL="http://www.filecrop.com"
Q=`url_encode_args q="$A"`
POS=1
: ${VERBOSE:="-s"}
QURL="${URL}/${Q#q=}.html"
REFERER=""
CURL="check_cookies; set ${DEBUG:-+x}; curl -q \${VERBOSE} -L \${COOKIE_ARGS} \${REFERER:+--referer \"\${REFERER}\"} \${SOCKS5:+-socks5 \"\${SOCKS5}\"} -A \"\${USER_AGENT}\""
CMD="${CURL} \${QURL}"
FILTER="xml_get a href |${SED-sed} -n 's,^/\([0-9]*/index.html\)$,${URL}/\1,p; s,\(.*search.php.*pos=.*\),${URL}/\1,p'"

check_cookies()
{
 [ -e "$COOKIES"  -a -r "$COOKIES" -a -s "$COOKIES" ] && READ_COOKIES="$COOKIES" || unset READ_COOKIES
 WRITE_COOKIES="$COOKIES" || unset WRITE_COOKIES

 COOKIE_ARGS="${READ_COOKIES:+--cookie
$READ_COOKIES}${WRITE_COOKIES:+--cookie-jar
$WRITE_COOKIES}"

}
while [ "$QURL" ]; do
  #echo "POS=$POS" 1>&2 

case "$QURL" in
  *://*) ;; 
  *) QURL="$URL/$QURL" ;;
esac
  DATA=`eval "($CMD)"`
  URLS=`echo "$DATA" | eval "$FILTER"`

	if [ -z "$URLS" ]; then
		echo -e "No results\!" 1>&2 
		if ${GREP-grep -a --line-buffered --color=auto} -q -E '(recaptcha)' <<<"$DATA"; then
        REFERER="$QURL"
			QURL=$(echo "$DATA" | xml_get iframe src )
			if [ -z "$QURL" ]; then
				QURL=$(echo "$DATA" | xml_get img src)
			fi
			echo -e "Recaptcha! ($QURL)" 1>&2
			continue
		else
      echo "$DATA" | file -
    fi
	  exit
	fi
  QURL=
	for URL in $URLS; do
echo "URL=$URL" 1>&2
		case "$URL" in 
      */index.html) echo "$URL" ;; 
			*pos=[0-9]*) 
          I=${URL##*pos=}
          I=${I%%[!0-9]*}
          #echo "I=${I}" 1>&2  
          ;;
      *) I= ;;
		esac
    if [ "$I" ]; then
			if [ "$I" -le "$POS" ]; then
				POS="$I"
				continue
			fi
			if [ "$I" -gt "$POS" ]; then
				 QURL="${QURL:+$QURL
	}$URL"
         POS="$I"
         break 
	     fi
    fi
	done |cat  
done
