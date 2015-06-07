#!/bin/sh
# $Id: pdfopt 8773 2008-05-25 02:17:14Z alexcher $
# Convert PDF to "optimized" form.

# This definition is changed on install to match the
# executable name set in the makefile
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
	*)  break ;;
	esac
	shift
done

if [ $# -ne 2 ]; then
	echo "Usage: `basename $0` input.pdf output.pdf" 1>&2
	exit 1
fi

exec "$GS_EXECUTABLE" -q -dNODISPLAY $OPTIONS -- "$1" "$2"
