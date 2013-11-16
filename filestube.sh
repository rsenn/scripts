#!/bin/bash
. require.sh

require url
require xml

X="+x"
N=99
Q=`url_encode_args q="$@"`
IFS="
 "
(

SEQ=$(set -- `seq -s , 1 $N`; IFS=","; echo "${*%,}")

#echo "CMD='$CMD' SEQ='$SEQ'" 1>&2
#eval "$CMD"
CMD="curl -q --location -s \"http://www.filestube.com/look_for.html?${Q}&select=All&Submit=Search&${HOSTING:+hosting=${HOSTING}&}page=\"{$SEQ}"
echo "$CMD" 1>&2

eval "(set ${X:--x}; $CMD)") |
sed -u 's,<a,\n&,g ; s,</a>,&\n,g' | sed -n "/\"resultsLink\"/ s|\(href=\"\?\)\(/\)|\1http://www.filestube.com\2|p" |xml_get a href |
#sed -u -n 's,^<a href="\([^"]*.html\)".*resultsLink.*,http://www.filestube.com\1,p'   | 
while read -r LINK; do

    (   curl -s "$LINK" )  |xml_get 'pre id="copy_paste_links"[^>]*'
  #|xml_get 'pre id="copy_paste_links" style="clear:both;padding: 6px; border: 1px inset #ccc; width: 590px;text-align: left;background:#fff;overflow:auto;max-height:500px; height:32px;"')

done | sed -u '/^\s*$/d'
