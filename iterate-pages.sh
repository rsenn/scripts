#!/bin/bash
IFS="
"

explode() {
 (S="$1"; shift
  IFS="
"
  [ $# -gt 0 ] && exec <<<"$*"
  sed "s|${S//\"/\\\"}|\n|g")
}

implode() {
 (unset DATA SEPARATOR;
  SEPARATOR="$1"; shift
  CMD='DATA="${DATA+$DATA$SEPARATOR}$ITEM"'
  if [ $# -gt 0 ]; then
    CMD="for ITEM; do $CMD; done"
  else
    CMD="while read -r ITEM; do $CMD; done"
  fi
  eval "$CMD"; echo "$DATA")
}

match() {
 (PATTERN="$1"; shift
  RET=1
  for ARG; do
    case "$ARG" in
      $PATTERN) RET=0; echo "$ARG" ;;
    esac
  done
  exit $RET)
}

get_url_args() {
  URL_BASE=${URL%%"?"*}
  URL_ARGS=`explode "&" "${URL#"$URL_BASE?"}"`
}

main() {
  while :; do
	case "$1" in
	  -d | --debug) DEBUG="true"; shift ;;
	  -p | --print) EVALCMD="echo"; shift ;;
	  *) break ;;
	esac
  done

  for URL; do

  (get_url_args "$URL" 
   
   A=`match "page=[0-9]*" $URL_ARGS`
   R=$(sed <<<"$A" 's,\(.*\)=\([0-9]\+\)$,\\(\1\\)=\\(\[0-9\]\\+\\),')
   P=$(sed <<<"$A" "s|$R|\2|")
   
   CMD="extract-urls.sh '$(echo "$URL" | sed "s|$R|\1='{\`seq -s, 1 $P\`}'|")'"
   
   [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
   
   ${EVALCMD:-eval} "$CMD")
  done
}

main "$@"