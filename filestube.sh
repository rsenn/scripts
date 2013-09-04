#!/bin/bash
. require.sh

require url
require xml

X="+x"
N=99
Q=`url_encode_args q="$@"`
(  CMD="curl -q -s \"http://www.filestube.com/look_for.html?${Q}&select=All&Submit=Search&${HOSTING:+hosting=${HOSTING}&}page=\""{`seq -s, 1 $N `}""
echo "$CMD" 1>&2
eval "(set ${X:--x}; $CMD)") |
sed -u 's,<a,\n&,g ; s,</a>,&\n,g' |
sed -u -n 's,^<a href="\([^"]*.html\)".*resultsLink.*,http://www.filestube.com\1,p'   | 
while read -r LINK; do

    (   curl -s "$LINK" )  |xml_get 'pre id="copy_paste_links"[^>]*'
  #|xml_get 'pre id="copy_paste_links" style="clear:both;padding: 6px; border: 1px inset #ccc; width: 590px;text-align: left;background:#fff;overflow:auto;max-height:500px; height:32px;"')

done | sed -u '/^\s*$/d'
