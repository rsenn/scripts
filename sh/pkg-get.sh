#!/bin/bash

. require.sh

require xml

: ${CURL_ARGS="-s"}

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
    slacky) dlynx.sh http://slackware.org.uk/slacky/|grep /slacky/.*/|addsuffix PACKAGES.TXT ;;
    ubuntu) list http://ch.archive.ubuntu.com/ubuntu/dists/${RELEASE-trusty}{,-backports,-proposed,-security,-updates}/{main,universe,multiverse,restricted}/binary-${ARCH-amd64}/Packages.gz ;;
    msys)  curl -s ftp://netix.dl.sourceforge.net/sourceforge/m/mi/mingw/Installer/mingw-get/catalogue/msys-package-list.xml.lzma |lzcat |xml_get package-list catalogue | sed 's|.*|ftp://netix.dl.sourceforge.net/sourceforge/m/mi/mingw/Installer/mingw-get/catalogue/&.xml.lzma|'  ;;

  esac
}

read_package_lists() {

  for ARG; do
    (case "$ARG" in
      */slacky/*)  ;;
      */ubuntu/*) BASE=${ARG%%/ubuntu/*}/ubuntu ;;
    esac

    DLCMD='curl $CURL_ARGS "$ARG"'
    case "$ARG" in 
       *.bz2) DLCMD="$DLCMD | bzcat" ;;
       *.gz) DLCMD="$DLCMD | zcat" ;;
       *.xz) DLCMD="$DLCMD | xzcat" ;;
       *.lzma) DLCMD="$DLCMD | lzcat" ;;
    esac

    eval "$DLCMD" | while read -r LINE; do 
      P=${LINE%%": "*}
      V=${LINE##*": "}
      V=${V#" "}
      V=${V#" "}
      V=${V#" "}
      
      case "$P" in
          "Filename")         NAME="${V##*/}" LOCATION="${V%/*}" ;; 
          *tarname=*%*)     ;;
          *tarname=*)         NAME=${LINE##*tarname=\"}; NAME=${NAME%%\"*} ;;
          "PACKAGE NAME")     NAME="$V" ;;
          "PACKAGE LOCATION") LOCATION="${V#./}" ;;
          "")                 [ "$NAME" ] && echo "${BASE:-${ARG%/*}}/$LOCATION/$NAME" ;;
          *"</"*)         [ "$NAME" ] && echo "$BASE/$NAME" ; NAME= ;;
      esac
    done)
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
  [ -n "$2" ] && RELEASE="$2"
  [ -n "$3" ] && ARCH="$3"

  set -- $(get_package_lists "$DIST")
  echo "Package lists:" "$@" 1>&2
   
  read_package_lists "$@"
}
list() {
   (IFS="
"; echo "$*")
}

pkg_get "$@"
