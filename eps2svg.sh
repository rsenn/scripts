#!/bin/sh

# eps2svg: EPS to SVG vector command line image converter
# David Griffith <davidgriffith@acm.org>
# Created March 30, 2009 and released into the public domain
# The programs pstoedit and skencil are required.

EXT="svg"
USAGE="usage: eps2svg [-v] input.eps [output.svg]\n  -v verbose mode"

while getopts qh OPTION
do
	case "$OPTION" in
	v)	VERBOSE=true; shift;;
	h)	echo $USAGE; exit 1;;
	\?)	echo $USAGE; exit 1;;
	*)	echo $USAGE; exit 1;;
	esac
done

FROM=$1

if [ -z $FROM ]; then
	echo $USAGE
	exit
fi

if [ -z $2 ]; then
	TO=`echo "$1" | awk -F. '{ORS="";\
				for (i=1; i<NF-1; i++) {\
					print $(i);\
					print ".";\
				}\
				print $(i);\
				print "\n";\
				}'`
	TO=`echo $TO.$EXT`
else
	TO=$2
fi

if [ `echo $TO | grep -v 'svg$'` ]; then
	TO="$TO.svg"
fi

if [ $VERBOSE ]; then
	echo "Converting from $FROM to $TO"
fi

MYNAME=eps2svg
TMPDIR=/tmp
SCRATCH="/tmp/eps2svg-$$"

if [ ! -r $FROM ]; then
	echo "ERROR: Cannot read file \"$FROM\"." 1>&2
	exit
fi

if [ -e $SCRATCH ]; then
	echo "ERROR: Scratch file $SCRATCH already exists." 1>&2
	echo "  Please delete all files beginning with $MYNAME in" 1>&2
	echo "  $TMPDIR that belong to you and try again." 1>&2
	echo 1>&2
	exit
fi

# Assure the file is removed at program termination
# or after we received a signal:
trap 'rm -f "$SCRATCH" >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 13 15
EXINIT="set ignorecase nowrapscan readonly"
export EXINIT

pstoedit -page 1 -dt -psarg "-r9600x9600" -f sk $FROM $SCRATCH > /dev/null 2>&1  
skconvert $SCRATCH $TO
rm -f $SCRATCH
