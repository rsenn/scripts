#!/bin/bash


addsuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "$LINE$SUFFIX"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}



get_package_lists() {

  case "$1" in
    slacky) 
      dlynx.sh http://slackware.org.uk/slacky/|grep /slacky/.*/|addsuffix PACKAGES.TXT ;;
  esac
}

read_package_lists() {

  for ARG; do
    case "$ARG" in
      */slacky/*) 

        ;;
    esac

		curl -s "$ARG" | while read -r LINE; do 
		   P=${LINE%%": "*}
			 V=${LINE##*": "}
			 V=${V#" "}
			 V=${V#" "}
			 V=${V#" "}
			 
		   case "$P" in
							 "PACKAGE NAME") NAME="$V" ;;
							 "PACKAGE LOCATION") LOCATION="${V#./}" ;;
							 "") [ "$NAME" ] && echo "${ARG%/*}/$LOCATION/$NAME" ;;
			 esac

    done
	done

}

pkg_get() {

  while :; do
    case "$1" in
      -h | -? | --help) usage; exit 0 ;;
      *) break ;;
    esac
  done

	DIST="$1"
  [ -z "$DIST" ] && DIST="slacky"
	
  set -- $(get_package_lists "$DIST")
	echo "Package lists:" "$@" 1>&2
	 
	read_package_lists "$@"
}

pkg_get "$@"
