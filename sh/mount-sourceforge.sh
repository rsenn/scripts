#!/bin/bash

MYNAME=`basename "$0" .sh`
ARGC=0

set -f

while :; do
  [ $# = 0 ] && break
  case "$1" in
	  -d | -f | -h | -l | -o | -s | -u | -V | -z) SWITCHES="${SWITCHES:+$SWITCHES
}$1"; shift; continue ;;	
    -p) PROJECT=$2; shift 2; continue ;;
	  -o) OPTS="${OPTS:+$OPTS,}$2"; shift 2; continue ;;
	  -t) TYPE="$2"; shift 2; continue ;;
	  *) case $ARGC in
						0) DEV="$1"; shift; : $((ARGC++)); continue ;;
						 1) MNT="$1"; shift; : $((ARGC++)); continue ;;
			 esac ;;
  esac
done

: ${MNT:=/media/${MYNAME#mount-}}

set -x

if [ -n "$PROJECT" ]; then
				LETTER=${PROJECT:1:1}
				LETTERS=${PROJECT:1:2}

				URL="ftp://netix.dl.sourceforge.net/sourceforge/$LETTER/$LETTERS/project/$PROJECT/"

        exec curlftpfs "$URL" "$MNT" ${OPTS:+-o $OPTS}
fi	


OPTS=${OPTS//'\040'/' '}
OPTS=${OPTS//'\x20'/' '}

OPTS="${OPTS:+$OPTS,}mount_template=mount-sourceforge.sh x %m -p %r,unmount_template=fusermount -z -u %m"
set -x
exec afuse "$MNT" $SWITCHES -o "$OPTS"
