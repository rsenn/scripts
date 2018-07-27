#!/bin/bash
# $Id: pdfopt 8773 2008-05-25 02:17:14Z alexcher $
# Convert PDF to "optimized" form.

# This definition is changed on install to match the
# executable name set in the makefile

THISDIR=`dirname "$0"`

filesize() {
  
 (IFS=" " ; set -- `ls -lnd  -- "$1"`
  echo $5)
}
explode_1() {
 (IFS="$1"; shift; set -- $*; IFS="
"; echo "$*")
}
implode() {
  (IFS="${1:1:1}"; shift; echo "$@")
}

pdfopt() {

  show_ratio() {
    : ${IN_SIZE:=`filesize "$IN"`}
    : ${OUT_SIZE:=`filesize "$OUT"`}
    RATIO=`echo "scale=3; $OUT_SIZE * 100 / $IN_SIZE" |  bc -l`
  }

  method_binary() {
   (eval "set -- $(method_cmd="$1"); echo \$1")
   
  }

  method_cmd() {
    case "$1" in
      gs) CMD='"$GS_EXECUTABLE" -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dColorImageDownsampleType=/Bicubic -dColorImageResolution=72 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=72 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=72 -sOutputFile="$OUT" "$IN"' ;;
      pdftk) CMD='pdftk "$IN" output "$OUT" compress' ;;
      ps2pdf) CMD='ps2pdf -dPDFSETTINGS=/ebook "$IN" "$OUT"' ;;
      *magick) CMD='convert -density 300x300 -quality 95 -compress jpeg "$IN" "$OUT"' ;;
      qpdf) CMD='qpdf --stream-data=compress "$IN" "$OUT"' ;;
      #k2pdfopt) CMD='k2pdfopt "$IN" -o "$OUT" -ocr -ocrlang eng -dev kpw -bp -x' ;;
      pdftocairo) CMD='pdftocairo "$IN" -pdf "$OUT"' ;;
    esac
  }

  ALL_METHODS=$(declare -f method_cmd | sed -n "1d; /)/ { s|^\\s*||; s|).*||; s|\\*||g; p }" )
  [ "$DEBUG" = true ] && echo "ALL_METHODS" = $ALL_METHODS 1>&2


  GS_EXECUTABLE=gs
  gs="`dirname $0`/$GS_EXECUTABLE"
  if test ! -x "$gs"; then
    gs="$GS_EXECUTABLE"
  fi
  GS_EXECUTABLE=gs

  OPTIONS="-dSAFER -dDELAYSAFER"
  while [ $# -gt 0 ]; do
    case "$1" in
      --methods=* | -M=* ) METHODS=$(explode_1 , ${1#*=}) ;;
      --methods | -M ) METHODS=$(explode_1 , ${2}); shift ;;
      -M*) METHODS=$(explode_1 , ${1#-M}) ;;

      -x | -d | --debug) DEBUG=true ;;
      -i) INPLACE=true ;;
      -r | --show-ratio) SHOW_RATIO=true ;;
      -?*) OPTIONS="$OPTIONS $1" ;;
      *)  break ;;
    esac
    shift
  done

  [ -z "$METHODS" ] && METHODS=$ALL_METHODS

  [ "$DEBUG" = true ] && echo "METHODS" = $METHODS 1>&2
  N_METHODS=$(set -- $(explode_1 , $METHODS); echo $#)
  [ "$N_METHODS" -gt 0 ] || METHODS=gs

  if [ $# -lt 1 ]; then
    echo "Usage: `basename $0` [OPTIONS] input.pdf [output.pdf]" 1>&2
    exit 1
  fi

  if [ -z "$LOOP_CMD" ]; then
      LOOP_CMD='pdfopt "$ARG"; E=$?; R=$((R & E))'
    [ "$SHOW_RATIO" = true ] && LOOP_CMD='SHOW_RATIO= '$LOOP_CMD
    [ $N_METHODS -gt 1 ] && LOOP_CMD='for METHOD in $METHODS; do METHOD=$METHOD '$LOOP_CMD'; done; show_ratio'
    [ "$SHOW_RATIO" = true ] && LOOP_CMD=$LOOP_CMD'; echo "${NAME:+$NAME: }$RATIO"'
    LOOP_CMD='R=127; '$LOOP_CMD'; [ $R = 0 ] || break'
    LOOP_CMD='for ARG; do '$LOOP_CMD'; done'
    echo "LOOP_CMD='$LOOP_CMD'" 1>&2
      eval "$LOOP_CMD"
    
      exit $?
  fi

  CMD=
  TEMP=
  method_cmd "$METHOD"
  : ${CMD:='"$GS_EXECUTABLE" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$OUT" "$IN"'}

  CMD='([ "$DEBUG" = true ] && set -x; exec '$CMD')'

  [ "$SHOW_RATIO" = true ] && 
    CMD="$CMD; R=\$?; show_ratio; echo \"\${NAME:+\$NAME: }\$RATIO\"" ||
    CMD="$CMD; R=\$?; show_ratio"
  IN="$1" 

  NAME=
  if [ -n "$2" ]; then
    OUT="$2"
  else
    if [ "$INPLACE" = true ]; then
      TEMP=`mktemp XXXXXX.pdf`
      OUT=$TEMP
      CMD=${CMD%"; return"*}'; [ $R = 0 ] && [ ${RATIO%%.*} -lt 100 ] && mv -f -- "$OUT" "$IN"'
      NAME="$IN"
    else
      OUT="${IN%.*}.out.${IN##*.}"
    fi
  fi

  : ${NAME:="$OUT"}

  IN_SIZE=$(filesize "$IN")
  OUT_SIZE=

    #[ "$INPLACE" = true ] && CMD=${CMD%"; return"*}'; OUT=$IN; return $R'

  [ "$DEBUG" = true ] && echo "CMD=$CMD" 1>&2
  #exec "$GS_EXECUTABLE" -q -dNODISPLAY $OPTIONS -- "$1" "$2"


  eval "$CMD"
  [ -n "$TEMP" -a -e "$TEMP" ] && rm -f "$TEMP"
  return $R
}

case "$0" in
  -*) break ;;
  *) pdfopt "$@" ;;
esac
