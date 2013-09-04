#!/bin/bash

SERVER="https://webdav.4shared.com:443"
CURLARGS="-q
-#"
IFS="
"
USER="roman.l.senn@gmail.com"
PASS="lalala"

curl-upload()
{ for ARG; do
  (set -x; 
    BASE=${ARG##*/}; 
    curl $CURLARGS -u "$USER:$PASS" --upload-file "$ARG" "$SERVER"${DIR+/"$DIR"}/"$BASE" )
done
}

curl-upload "$@"

