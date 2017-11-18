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

search_package() {
  Q="$1"
  case "$DIST" in
    slackware) urlfmt="https://packages.slackware.com/?search=%s&release=slackware-current&mode=package&extra=on&patches=on&slackware=on" ;;
    debian) urlfmt="https://packages.debian.org/search?searchon=contents\&keywords=%s\&mode=path\&suite=${SUITE=stable}\&arch=any" ;;
    ubuntu) urlfmt="https://packages.ubuntu.com/search?keywords=%s\&searchon=names\&suite=${SUITES="{trusty,trusty-updates,trusty-backports}"}\&section=all" ;;
    fedora) urlfmt="https://apps.fedoraproject.org/packages/s/%s" ;;
    opensuse) urlfmt="https://software.opensuse.org/search?utf8=%E2%9C%93&q=%s&search_devel=false&search_unsupported=false&baseproject=openSUSE%3ALeap%3A42.2" ;;
    archlinux) urlfmt="https://www.archlinux.org/packages/?sort=&q=%s&maintainer=&flagged=" ;;
    pbone) urlfmt="http://rpm.pbone.net/index.php3?stat=3&search=%s&Search.x=0&Search.y=0&simple=1&srodzaj=4" ;;
  esac
  #echo "set -- $urlfmt" 1>&2
  eval "set -- $urlfmt"
  echo "ARGS: ${NL}$*" 1>&2
  for FMT; do 
  printf "$FMT\\n" "$Q" 
done
}

pkg_search() {
  IFS="
"
NL="
"

  while :; do
    case "$1" in
      -h |  --help) usage; exit 0 ;;
      -d | --dist) DIST="$2"; shift 2 ;; -d=* | --dist=*) DIST="${1#*=}"; shift ;;
      -a | --arch) ARCH="$2"; shift 2 ;; -a=* | --arch=*) ARCH="${1#*=}"; shift ;;
      -s | --suite) IFS="," pushv SUITES "$2"; shift 2 ;; -s=* | --suite=*) IFS="," pushv SUITES "${1#*=}"; shift ;;
      *) break ;;
    esac
  done

  case "$SUITES" in
    *,*) SUITES="{$SUITES}" ;;
  esac
  #DIST="$1"
  [ -z "$DIST" ] && DIST="ubuntu"
  [ -z "$ARCH" ] && ARCH=`uname -m`
  #[ -n "$2" ] && RELEASE="$2"
  #[ -n "$3" ] && ARCH="$3"

  set -- $(search_package "$@")


  echo "Package searches:" "$*" 1>&2

    dlynx.sh "$@"
   
}
list() {
   (IFS="
"; echo "$*")
}

pushv () 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
pkg_search "$@"
