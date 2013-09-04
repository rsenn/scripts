#!/bin/bash

SET1='+"rapidshare.com/files"|"megaupload.com/?d="|"www.mediafire.com/"|"hotfile.com/dl"|"depositfiles.com/files"|"uploading.com/files/"'
SET2='+"netload.in/"|"www.filefactory.com/file/"|"www.sendspace.com/file/"|"www.badongo.com/file/"|"uploadbox.com/files/"|"letitbit.net/download/'
SET3='+"sharingmatrix.com/file/"|"www.box.net/shared/"|"kewlshare.com/dl/"|"saveqube.com/getfile/"|"www.4shared.com/file/"|"www.ziddu.com/download/"|"www.zshare.net/download/"'

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
