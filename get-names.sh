#!/bin/bash

. require.sh

require xml
require var

TMP=`mktemp`
BASE=`basename "$0" .sh`
COOKIE="$BASE.cookie"

 for l in a b c d e f g h i j k l m n o p q r s t u v w x y z
 do 
	 g=`echo "$l" | tr [:{lower,upper}:]`
	 PREVURL=""
	 URL="http://www.babycenter.ch/babyname/vornamen-mit-$l?babyName=$g&runSearch=true&preserveUrl=true"
          
	 while [ "$URL" ]; do
	   HTML=`set -x; curl -q -s ${PREVURL:---cookie-jar "$COOKIE"} ${PREVURL:+--cookie "$COOKIE" --location --referer "$PREVURL"} "$URL"`
	   PREVURL="$URL"
	   URL="$(echo "$HTML" |grep '>&gt;<' |xml_get a href | tail -n1)"
	   [ "$URL" ] && URL="http://www.babycenter.ch$URL"

#	   echo "$URL" 1>&2 
	   echo "$HTML"
         done
 done | xml_get 'p class="evenRow"' | 
 sed -u -e 's,^\s\+,,' -e 's,&mdash;,-,' | {
 echo '"Name","Bedeutung","Link"'
 while :; do
   read -r A || break
   read -r B || break
   read -r C || break
   read -r D || break

   B=${B#"<a href=\""}
   B=${B%"\">"}
   B="http://www.babycenter.ch$B"

   D=${D#"- \""}
   D=${D%"\"</a>"}

   case "$D" in
	    *\"*) D="" ;;
    esac

   echo "\"$C\",\"$D\",\"$B\""
#   var_dump A B C D 
done

} | { tee "$BASE.csv"; wc -l "$BASE.csv"; }
