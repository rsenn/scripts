#!/bin/sh
DIR=`dirname "$_"`

# mingwpath [-muw] [path]
mingwpath()
{
 (T=u IFS=/\\ S=/
  case $1 in
    -m) T=m S=/; shift ;;
    -w) T=w IFS=\\/ S=\\; shift ;;
    -u) shift ;;
    -*) exit 1 ;;
  esac
  set -- $*
  case "$1¦$2¦$T" in
    [A-Za-z]":¦"*"¦"u) DRV=${1%:}; shift; set "/$DRV" "$@" ;;
    "¦"[A-Za-z]"¦"[mw]) DRV=${2#/}; shift 2; set "$DRV:" "$@" ;;
  esac
  echo "$*")
}
