#!/bin/bash

SET1='+"share-online.biz/dl/"|"zippyshare.com/"|"mediafire.com/"|"uploadable.ch/"|"depositfiles.com/files"|"uploaded.net/"'
SET2='+"netload.in/"|"filefactory.com/file/"|"sendspace.com/file/"|"badongo.com/file/"|"uploadbox.com/files/"|"letitbit.net/download/'
SET3='+"sharingmatrix.com/file/"|"box.net/shared/"|"kewlshare.com/dl/"|"mega.co.nz/"|"4shared.com/file/"|"ziddu.com/download/"|"zshare.net/download/"'

NAME=`echo "$*" | sed -e 's,[^0-9A-Za-z]\+,-,g' -e 's,^[^0-9A-Za-z]\+,,' -e 's,[^0-9A-Za-z]\+$,,'`

echo "Canonical name is $NAME" 1>&2

#IFS=" $IFS"
IFS=" °"

KEYWORDS="$*"
OUTPUT="$NAME.list"

{ RESULTS=1000
  
 (set -x
  google.sh "$KEYWORDS $SET1"
  google.sh "$KEYWORDS $SET2"
  google.sh "$KEYWORDS $SET3")

} \
  | xargs -n10 -d "
" extract-urls.sh \
  | file-hoster-urls.sh \
  | uniq \
  | tee "$OUTPUT"
 
wc -l "$OUTPUT"
