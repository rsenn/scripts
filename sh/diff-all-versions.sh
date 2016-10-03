#!/bin/bash

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

set_list() {
  local IFS="
"
  eval "shift; $1=\"\$*\""
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
  eval "$CMD"
  echo "$DATA")
}

main() {
#  : ${DIFF:="udiff.sh"}
  : ${DIFF:="diff"}

  : ${DIFFOPTS:="-r -N"}

  set_list EXCLUDE ".git*" ".cvs*" ".svn*" "*#*" "*.rej" "*.orig" "*~"

  while :; do
    case "$1" in
      -p | --print*) PRINT_ONLY=true; shift ;;
      -x | --debug*) DEBUG=true; shift ;;
      -w | --whitespace*) WHITESPACE=ignore; shift ;;
      -U[0-9]* ) FORMAT=unified${1#-?}; shift ;; -U=[0-9]* ) FORMAT=unified${1#*=}; shift ;; -U) FORMAT=unified${2}; shift 2 ;; 
      -u | --unified*) FORMAT=unified; shift ;;
      *) break ;;
    esac
  done
  
  [ "$WHITESPACE" = ignore ] && DIFFOPTS="$DIFFOPTS -w"
  case "$FORMAT" in
     unified) DIFFOPTS="$DIFFOPTS -u" ;;
     unified*) DIFFOPTS="$DIFFOPTS -U${FORMAT#unified}" ;;
  esac     
  
  DIFFOPTS="$DIFFOPTS -x{"$(${SED-sed} "s|.*|'&'|" <<<"$EXCLUDE" | implode ",")"}"

	NAME=`get_name "$1"`
	OLD_VERSION=`get_version "$1"`

	while [ $# -gt 1 ]; do
		PREV="$1"
		shift
		THIS="$1"
		NEW_VERSION=`get_version "$1"`
		CMD="$DIFF${DIFFOPTS:+ $DIFFOPTS} "$(make_filename "$PREV")" "$(make_filename "$THIS")
		
		DIFFNAME="$NAME-${OLD_VERSION}-to-${NEW_VERSION}"
		[ "$WHITESPACE" = ignore ] && DIFFNAME="$DIFFNAME-w"
		
		CMD="$CMD >"$(make_filename "${DIFFNAME}.diff")
		
		[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
		if [ "$PRINT_ONLY" = true ]; then
		  echo "$CMD"
		else
		  
		  	[ "$DEBUG" = true ]  || echo "$CMD" 1>&2
		  eval "$CMD"
		fi
		
		OLD_VERSION=$NEW_VERSION
	done
}

main "$@"
