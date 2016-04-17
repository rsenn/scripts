#!/bin/bash

. require.sh

require xml
require archive

view_genres()
{
	curl "http://modarchive.org/index.php?request=view_genres"|
	xml_get "li class='bigbiglink'" |while read -r LINE; do


		href=`xml_get a href <<<"$LINE"` 
		title=`${SED-sed} "s,.*>\([^<]\+\)<.*,\1,"  <<<"$LINE"` 

		test -n "$title" && echo http://modarchive.org/$href "$title"
	done
}


list_genre()
{
(IFS="
"
URLS=`curl "http://modarchive.org/index.php?query=${1}&request=search&search_type=genre" |
   ${GREP-grep -a --line-buffered --color=auto} -E '(view_by_moduleid|page=[0-9])' |xml_get a href` 




NPAGE=`${SED-sed} -n 's,.*page=\([0-9]*\).*,\1,p' <<<"$URLS" | sort -n  |tail -n1` 

eval "set http://modarchive.org/index.php?query=${1}\\&request=search\\&search_type=genre\\&page="{` seq -s, 1 $NPAGE`}


#set -- `grep view_by_moduleid <<<"$URLS"` 

dlynx.sh "$@" |grep view_by_moduleid |while read -r URL; do

  dlynx.sh  "$URL"
done
)

}

list_genre "$@"
