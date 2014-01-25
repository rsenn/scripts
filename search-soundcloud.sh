#!/bin/bash

IFS="
"

. require.sh

require xml
require url
#require http

USER_AGENT="Mozilla/5.0 (Windows NT 5.1; rv:21.0) Gecko/20100101 Firefox/21.0 SeaMonkey/2.18"

http_get()
{
case "${OS=`uname -o`}" in
  Cygwin*) CMD='curl --insecure --location --user-agent "$USER_AGENT" "$@"' ;;
   *) CMD='wget --no-check-certificate -q --user-agent="$USER_AGENT" -O - "$@"' ;;
   esac
   
   eval "(set -x; $CMD)"
}


 for ARG; 
 do 

	URL="http://soundcloud.com/search?$(url_encode_args "q%5Bfulltext%5D=$ARG")"
	echo "URL is $URL" 1>&2
	
  #LINKS=`(http_get "$URL") | sed "s|>\\s*<|>\\n<|g" `
  #echo LINKS = "$LINKS" 1>&2
  LINKS=`(set -x; curl --location  "$URL") | grep --line-buffered -E '<(h3|div class="pagination")>'  | xml_get a href`
	TRACKS=`echo "$LINKS" | grep -v page=`
	NAV=`echo "$LINKS" | sed -n 's,.*page=\([0-9]\+\).*,\1,p'`
	BROWSE=`echo "$LINKS" | sed -n "/page=/ { s,^,http://soundcloud.com, ; s,\\&amp;,\\\\\\\\\\&,g ; s,page=[0-9]\+,page=\\\${PAGE}, ; p ; q ; }"`
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

