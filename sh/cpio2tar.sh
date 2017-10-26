#!/bin/sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean help false            "show this help" h
DEFINE_boolean debug false           "enable debug mode" D
DEFINE_string  output ""             "output file" o
DEFINE_boolean gzip  false           "compress using gzip" z
DEFINE_boolean bzip2 false           "compress using bzip2" j
DEFINE_boolean lzma  false           "compress using lzma" a

FLAGS_HELP="usage: `basename "$0"` [options] [input] [[-o] output]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# ---------------------------------------------------------------------------
ME=`basename "$0" .sh`
TEMP=`mktemp -d "/tmp/${ME}.XXXXXXXXXX"`
INFILE=$1
OUTFILE=${FLAGS_output:-$2}

[ "$FLAGS_gzip" = "$FLAGS_TRUE" ] && OUTEXT=.gz && COMPRESS=gzip
[ "$FLAGS_bzip2" = "$FLAGS_TRUE" ] && OUTEXT=.bz2 && COMPRESS=bzip2
[ "$FLAGS_lzma" = "$FLAGS_TRUE" ] && OUTEXT=.lzma && COMPRESS=lzma

case $INFILE in
  -|"") unset INFILE ;;
  *) : ${OUTFILE:=${INFILE%.cpio}.tar${OUTEXT}} ;;
esac

case $OUTFILE in
  -|"") unset OUTFILE ;;
esac

trap 'rm -rf "$TEMP" "$OUTFILE"' HUP INT QUIT TERM
trap 'rm -rf "$TEMP"' EXIT

[ "$INFILE" ] && exec <$INFILE
[ "$OUTFILE" ] && exec >$OUTFILE

cd "$TEMP"

cpio -d -i 1>/dev/null &&
tar -c ${COMPRESS:+--use-compress-program="$COMPRESS"} .

rm -rf "$TEMP"
trap - HUP INT QUIT TERM
