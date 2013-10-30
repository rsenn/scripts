#!/bin/sh

urlescape()
{
  echo "$1" | 
    sed \
      -e 's,",%22,g' \
      -e 's,+,%2B,g' \
      -e 's,|,%7C,g' \
      -e 's,",%22,g' \
      -e 's,/,%2F,g' \
      -e 's, ,%20,g'
}

IFS="
"
ARGS="$*"

set -- 
for ARG in $ARGS; do
  #echo "ARG is $ARG" 1>&2
  set -- "$@" `urlescape "$ARG"`
  #echo "@ is $@" 1>&2
done

IFS="+$IFS"
#URL=`surfraw -p -escape-url-args="no" google -results="${RESULTS-30}" "$*"`

if [ -z "$RESULTS" ]; then
  RESULTS=30
fi

if [ "$RESULTS" -le 100 ]; then
  END=0
else
  END="$RESULTS"
  RESULTS=100
fi


URLS="http://www.google.com/search?q=$*&num=${RESULTS-30}"
I="$RESULTS"
while [ "$I" -lt "$END" ]; do
  URLS="${URLS:+$URLS
}http://www.google.com/search?q=$*&num=${RESULTS}&start=$I"
  I=$((I + RESULTS))
done

#echo "URL is $URL" 1>&2

dlynx.sh $URLS  |sed -n 's,^http.*://.*url?q=,,p' | sed 's,\&.*,, ; s,%26,\&,g ; s,%2B,+,g ; s,%3F,/,g ; s,%3D,=,g ; s,%25,%,g' 

  echo| sed "s,.*Search Results,," \
  | tee raw.html \
  | hxprintlinks \
  | sed -n "s,^<li>\(.*\)</li>\$,\1,p" \
  | sed \
	-e "/^\//d" \
	-e "/\.google/d" \
	-e "/google\./d" \
	-e "/:\/\//!d"


