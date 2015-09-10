#!/bin/sh

get_version() {
 (nover=${1%%[-_][0-9]*.*}
  echo "${1#$nover[-_]}")
}

get_name() {
  echo "${1%%[-_][0-9]*.*}"
}

main() {
  while :; do
    case "$1" in
      -p | --print*) PRINT_ONLY=true; shift ;;
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
		cmd="udiff.sh -ru '$PREV' '$THIS'"
		
		cmd="$cmd >'$NAME-${OLD_VERSION}-to-${NEW_VERSION}.diff'"
		
		echo "cmd: $cmd" 1>&2
		[ "$PRINT_ONLY" = true ] || eval "$cmd"
		
		OLD_VERSION=$NEW_VERSION
	done
}