#!/bin/bash

: ${TEMP=/tmp/}

SET1='+"mega.co.nz/"|"gboxes.com/"|"nitroflare.com/"|"turbobit.net/"|"zippyshare.com/"|"uploadable.ch/"|"depositfiles.com/"|"oron.com/"|"oboom.net/"'
SET2='+"mediafire.com/"|"uploaded.net/"|"netload.in/"|"filefactory.com/"|"sendspace.com/"|"badongo.com/"|"uploadbox.com/"|"letitbit.net/"'
SET3='+"sharingmatrix.com/"|"box.net/"|"bitshare.com/"|"mega.co.nz/"|"4shared.com/"|"ziddu.com/"|"zshare.net/"'

#IFS=" $IFS"
IFS=" °"
S="°"

pushv () 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

while :; do
  case "$1" in
    -s | --save-tmp) OPTS="${OPTS:+$OPTS$S}$1=${TEMP%[\\\\/}/`basename "${0%.sh}"`$$.txt"; shift ;;
		-x | --debug) pushv OPTS "$1"; DEBUG=true; shift ;;
    -v | --verbose | -s* | --save* | -t=* | --type=* | -c=* | --class=* | -n=* | --results=*) pushv OPTS "$1"; shift ;; 
    -p=*|--dl*prog*=*) PROG="${1#*=}";  shift ;; -p|--dlprog) PROG="$2";  shift 2 ;;
    *) break ;;
  esac
done

search_fileshare() {
  NAME=`echo "$*" | ${SED-sed} -e 's,[^0-9A-Za-z]\+,-,g' -e 's,^[^0-9A-Za-z]\+,,' -e 's,[^0-9A-Za-z]\+$,,'`
  echo "Canonical name is $NAME" 1>&2

  KEYWORDS="$*"
  OUTPUT="$NAME.list"

  { RESULTS=1000
	
   ([ "$DEBUG" = true ] && set -x
	google.sh ${PROG:+-p="$PROG"} $OPTS "$KEYWORDS $SET1"
	google.sh ${PROG:+-p="$PROG"} $OPTS "$KEYWORDS $SET2"
	google.sh ${PROG:+-p="$PROG"} $OPTS "$KEYWORDS $SET3")

  } \
	| xargs -n10 -d "
" extract-urls.sh \
	| file-hoster-urls.sh \
	| uniq \
	| tee "$OUTPUT"
   
  wc -l "$OUTPUT"
}

for ARG; do 
  search_fileshare "$ARG"
done
