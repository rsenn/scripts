#!/bin/sh
# $Id: pdfopt 8773 2008-05-25 02:17:14Z alexcher $
# Convert PDF to "optimized" form.

# This definition is changed on install to match the
# executable name set in the makefile

THISDIR=`dirname "$0"`

filesize() {
  
 (IFS=" " ; set -- `ls -lnd  -- "$1"`
  echo $5)
}

pdfopt() {

  show_ratio() {
    IN_SIZE=`filesize "$IN"`
    OUT_SIZE=`filesize "$OUT"`
    RATIO=`echo "$OUT_SIZE * 100 / $IN_SIZE" | bc -l`
    echo "${NAME:+$NAME: }$RATIO%"
  }



  GS_EXECUTABLE=gs
  gs="`dirname $0`/$GS_EXECUTABLE"
  if test ! -x "$gs"; then
    gs="$GS_EXECUTABLE"
  fi
  GS_EXECUTABLE=gs

  OPTIONS="-dSAFER -dDELAYSAFER"
  while true
  do
    case "$1" in
      -?*) OPTIONS="$OPTIONS $1" ;;
      -i) INPLACE=true ;;
      *)  break ;;
    esac
    shift
  done

  if [ $# -ne 2 ]; then
    echo "Usage: `basename $0` [OPTIONS] input.pdf [output.pdf]" 1>&2
    exit 1
  fi

  if [ -n "$1" -a -e "$1" ] &&
    [ -n "$2" -a -e "$2" ]; then
    for ARG; do
      pdfopt "$ARG" || break
    done
    return $?
  fi

  CMD='"$GS_EXECUTABLE" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$IN" "$OUT"'

  CMD="$CMD; $SHOW_RATIO"
  IN="$1"
  if [ -n "$2" ]; then
    OUT="$2"
  else
    if [ "$INPLACE" = true ]; then
      OUT=`mktemp`
      CMD="(set -e; $CMD)"' && mv -f -- "$OUT" "$IN"'
    else
      OUT="${IN%.*}.out.${IN##*.}"
    fi
  fi
  a

  #exec "$GS_EXECUTABLE" -q -dNODISPLAY $OPTIONS -- "$1" "$2"
  eval "$CMD"
}

pdfopt "$@"
