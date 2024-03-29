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
      #slacky) dlynx.sh http://slackware.org.uk/slacky/|grep /slacky/.*/|addsuffix PACKAGES.TXT ;; 
      slacky) dlynx.sh  http://repository.slacky.eu/ | grep slacky.eu/.*${RELEASE-14.2}.*/|addsuffix PACKAGES.TXT ;; 
      slackware) dlynx.sh http://slackware.cs.utah.edu/pub/slackware|grep /slackware/.*${RELEASE-14.2}.*/ | addsuffix PACKAGES.TXT ;; 
      ubuntu) list \
      ${URL-http://ch.archive.ubuntu.com/ubuntu}/dists/${RELEASE-trusty}{,-backports,-proposed,-security,-updates}/{main,universe,multiverse,restricted}/binary-${ARCH-amd64}/Packages.gz \
      http://archive.canonical.com/ubuntu/dists/${RELEASE-trusty}{,-proposed}/partner/binary-${ARCH-amd64}/Packages.gz \
      http://extras.ubuntu.com/ubuntu/dists/${RELEASE-trusty}/main/binary-amd64/Packages.gz
    ;;
  linuxmint) list \
    http://packages.linuxmint.com/dists/${RELEASE-sonya}/{main,universe,multiverse,backport,import,romeo,upstream}/binary-${ARCH-amd64}/Packages
  ;;
   debian) list http://cdn-fastly.deb.debian.org/$DIST/dists/$RELEASE{,-proposed-updates,-updates}/{main,non-free,contrib}/binary-${ARCH}/Packages.gz  ;;

    msys)  curl -s ftp://netix.dl.sourceforge.net/sourceforge/m/mi/mingw/Installer/mingw-get/catalogue/msys-package-list.xml.lzma |lzcat |xml_get package-list catalogue | sed 's|.*|ftp://netix.dl.sourceforge.net/sourceforge/m/mi/mingw/Installer/mingw-get/catalogue/&.xml.lzma|'  ;;

  esac
}

read_package_lists() {

  for ARG; do
    (case "$ARG" in
      */slacky/*)  ;;
      */ubuntu/*) BASE=${ARG%%/ubuntu/*}/ubuntu ;;
      */debian/*) BASE=${ARG%%/debian/*}/debian ;;
      *linuxmint*) BASE=${ARG%%/dists/*} ;;
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
usage() {

  echo "Usage: $(basename "$0" .sh) [OPTIONS] <ARGS...>
  -d, --dist    DIST      Distribution name (debian, ubuntu, archlinux, slackware, ...)
  -r, --release RELEASE   Release name 
  -a, --arch    ARCH      Architecture
  " 1>&2
  exit 0
}

pkg_get() {

  while :; do
    case "$1" in
      -d | --dist) DIST="$2"; shift 2 ;;
      -d=* | --dist=*) DIST="${1#*=}"; shift ;;
      -d*) DIST="${1#-d}"; shift ;;

      -u | --url) URL="$2"; shift 2 ;;
      -u=* | --url=*) URL="${1#*=}"; shift ;;
      -u*) URL="${1#-u}"; shift ;;

      -r | --release) RELEASE="$2"; shift 2 ;;
      -r=* | --release=*) RELEASE="${1#*=}"; shift ;;
      -r*) RELEASE="${1#-r}"; shift ;;

      -a | --arch) ARCH="$2"; shift 2 ;;
      -a=* | --arch=*) ARCH="${1#*=}"; shift ;;
      -a*) ARCH="${1#-a}"; shift ;;

      -x | --debug) DEBUG=true; shift  ;;
      -h | -? | --help) usage; exit 0 ;;
      *) break ;;
    esac
  done

  : ${DIST="$1"}
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
