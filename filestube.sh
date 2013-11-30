#!/bin/bash

. require.sh

require url

X="+x"
N=99
Q=`url_encode_args q="$@"`
IFS="
 "
(

SEQ=$(set -- `seq -s , 1 $N`; IFS=","; echo "${*%,}")

#echo "CMD='$CMD' SEQ='$SEQ'" 1>&2
#eval "$CMD"
CMD="curl -q --location  -s \"http://www.filestube.com/look_for.html?${Q}&select=All&Submit=Search&${HOSTING:+hosting=${HOSTING}&}page=\"{$SEQ}"
echo "$CMD" 1>&2

eval "(set ${X:--x}; $CMD)") |
sed 's,<,\n<,g' | 
#cat; echo |
sed -n "s|<a href=\"\([^\"]*\)\" *class=\"resultsLink\".*|http://www.filestube.com\1|p" |
while read -r LINK; do

				#echo "LINK=$LINK" 1>&2
    (   curl -q --location -s "$LINK" )  | 
		sed "s|>\s*<|>\n<|g" |
		sed -n '\|<pre| { :lp; N; \|</pre|! b lp; p; }' |
		sed "s|</\?pre[^>]*>||g"

done | sed -u '/^\s*$/d'
