#!/bin/bash

: ${TEMP=/tmp/}

SET1='+"share-online.biz/dl/"|"zippyshare.com/"|"mediafire.com/"|"uploadable.ch/"|"depositfiles.com/files"|"oron.com/"|"oboom.net/"'
SET2='+"uploaded.net/"|"netload.in/"|"filefactory.com/file/"|"sendspace.com/file/"|"badongo.com/file/"|"uploadbox.com/files/"|"letitbit.net/download/'
SET3='+"sharingmatrix.com/file/"|"box.net/shared/"|"kewlshare.com/dl/"|"mega.co.nz/"|"4shared.com/file/"|"ziddu.com/download/"|"zshare.net/download/"'

#IFS=" $IFS"
IFS=" °"

while :; do
  case "$1" in
    -s | --save-tmp) OPTS="${OPTS:+$OPTS
}$1=${TEMP%[\\\\/}/`basename "${0%.sh}"`$$.txt"; shift ;;
    -x | --debug | -v | --verbose | -s* | --save* | -t=* | --type=* | -c=* | --class=* | -n=* | --results=*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
    *) break ;;
  esac
done

NAME=`echo "$*" | ${SED-sed} -e 's,[^0-9A-Za-z]\+,-,g' -e 's,^[^0-9A-Za-z]\+,,' -e 's,[^0-9A-Za-z]\+$,,'`
echo "Canonical name is $NAME" 1>&2

KEYWORDS="$*"
OUTPUT="$NAME.list"

{ RESULTS=1000
  
 (set -x
  google.sh $OPTS "$KEYWORDS $SET1"
  google.sh $OPTS "$KEYWORDS $SET2"
  google.sh $OPTS "$KEYWORDS $SET3")

} \
  | xargs -n10 -d "
" extract-urls.sh \
  | file-hoster-urls.sh \
  | uniq \
  | tee "$OUTPUT"
 
wc -l "$OUTPUT"
