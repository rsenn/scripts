#!/bin/sh

url_decode() 
{
  OUT=$(echo "$@" | ${SED-sed} 's/+/ /g; s/%/\\x/g')
      
  ${ECHO-echo} -e "$OUT"
}

extract_imgurl() {

  URL="${1#*imgurl=}"
  URL="${URL%%"&"*}"

  url_decode "$URL" 

}

main() {
 
  if ! help echo >/dev/null 2>/dev/null || !(help echo |  grep -q '\-e') 2>/dev/null; then
    ECHO=$(which echo)
  fi


  if [ $# -gt 0 ]; then
    CMD='for ARG; do extract_imgurl "$ARG"; done'
  else
    CMD='while read -r ARG; do extract_imgurl "$ARG"; done'
  fi

  eval "$CMD"
}

main "$@"

