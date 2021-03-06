#!/bin/bash
NL="
"

: ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}
IFS="
"

. require.sh

require xml
require url
#require http

USER_AGENT="Mozilla/5.0 (Windows NT 5.1; rv:21.0) Gecko/20100101 Firefox/21.0 SeaMonkey/2.18"

http_get()
{
case "$OS" in
  Cygwin*) CMD='curl --insecure --location --user-agent "$USER_AGENT" "$@"' ;;
   *) CMD='wget --no-check-certificate -q --user-agent="$USER_AGENT" -O - "$@"' ;;
   esac
   
   eval "(set -x; $CMD)"
}


 for ARG; 
 do 

	URL="https://soundcloud.com/search?$(url_encode_args q="$ARG")"
	echo "URL is $URL" 1>&2
	
  #LINKS=`(http_get "$URL") | ${SED-sed} "s|>\\s*<|>\\n<|g" `

 # LINKS=`(set -x; curl --location  "$URL") | ${GREP-grep
-a
--line-buffered
--color=auto} -E '<(h3|div class="pagination")>'  | xml_get a href`
  LINKS=`extract-urls.sh "$URL"`
  echo LINKS = "$LINKS" 1>&2
	TRACKS=`echo "$LINKS" | ${GREP-grep
-a
--line-buffered
--color=auto} -v page=`
	NAV=`echo "$LINKS" | ${SED-sed} -n 's,.*page=\([0-9]\+\).*,\1,p'`
	BROWSE=`echo "$LINKS" | ${SED-sed} -n "/page=/ { s,^,http://soundcloud.com, ; s,\\&amp;,\\\\\\\\\\&,g ; s,page=[0-9]\+,page=\\\${PAGE}, ; p ; q ; }"`
  PAGES=1

  for P in $NAV; do
    if [ "$P" -gt "$PAGES" ]; then
      PAGES="$P"
     fi
  done
  echo $PAGES
  echo $BROWSE

PAGE={`seq -s , 2 $PAGES`}
eval "CMD=\"set -- $BROWSE\""
echo "CMD: $CMD" 1>&2
eval "$CMD"

  while [ "$TRACKS" ]; do
    echo "$TRACKS"  

    
    if [ "$1" ]; then 
      TRACKS=`(set -x; curl -s "$1") | xml_get h3 | xml_get a href`
  	else
			TRACKS=
    fi
    shift
  done | while read -r URL; do 
	case "$URL" in
					 *\?* | *=* | *\&* | /*/*/?*) ;;
					  /*/*/ | /*/*) echo "http://soundcloud.com$URL" ;;
		esac
		done


    

#http://soundcloud.com/tracks/search?q%5Bfulltext%5D=$n\\&page={"`seq -s , 1 16`"}"; 
  
	done
exit
#CMD="set -- http://soundcloud.com/tracks/search?q%5Bfulltext%5D=$n\\&page={"`seq -s , 1 16`"}"; 

echo "$CMD" 1>&2 ; 
eval "$CMD"; 

