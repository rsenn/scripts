#!/bin/sh

SQ="'"
DQ='"'
BS="\\"
FS="/"
NL="
"

get_version() {
 (nover=${1%%[-_][0-9]*.*}
  echo "${1#$nover[-_]}")
}

get_name() {
  echo "${1%%[-_][0-9]*.*}"
}

need_quoting() {
  case "$*" in
    *" "* | *"\t"* | *'"'* | *"'"*) return 0 ;;
    *) return 1 ;;
  esac
}

make_filename() {
 (NAME="${1}"
  case "$NAME" in
    */) ;;
    *) test -d "$NAME" && NAME="$NAME/" ;;
  esac
  if need_quoting "$NAME"; then
    NAME="'${NAME//"$SQ"/"$SQ$BS$SQ$SQ"}'"
  fi
  echo "$NAME")
}


main() {
  : ${DIFF:="udiff.sh"}
  : ${DIFFOPTS:="-ru -x{'.git*','.cvs*','.svn*','*#*','*.rej','*.orig','*~'}"}

  while :; do
    case "$1" in
      -p | --print*) PRINT_ONLY=true; shift ;;
      -x | --debug*) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  
	NAME=`get_name "$1"`
	OLD_VERSION=`get_version "$1"`

	while [ $# -gt 1 ]; do
		PREV="$1"
		shift
		THIS="$1"
		NEW_VERSION=`get_version "$1"`
		CMD="$DIFF${DIFFOPTS:+ $DIFFOPTS} "$(make_filename "$PREV")" "$(make_filename "$THIS")
		
		CMD="$CMD >"$(make_filename "$NAME-${OLD_VERSION}-to-${NEW_VERSION}.diff")
		
		[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
		if [ "$PRINT_ONLY" = true ]; then
		  echo "$CMD"
		else
		  eval "$CMD"
		fi
		
		OLD_VERSION=$NEW_VERSION
	done
}

main "$@"