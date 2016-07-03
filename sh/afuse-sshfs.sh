#!/bin/sh

MYNAME=${0%.sh}
ABSME=`realpath "$0"`
IFS="
"
unset ARGUMENTS

while [ $# -gt 0 ]; do
    case "$1" in
        -d | -x | --debug) DEBUG=1; shift ;;
        -o) OPTIONS="$2"; shift 2 ;;
        *) ARGUMENTS=${ARGUMENTS:+$ARGUMENTS
}$1; shift ;;
    esac
done

case "$OPTIONS" in
    *,debug) DEBUG=1; OPTIONS=${OPTIONS%,debug} ;;
    *,debug,*) DEBUG=1; OPTIONS=${OPTIONS//,debug,/,} ;;
    debug,*) DEBUG=1; OPTIONS=${OPTIONS#debug,} ;;
    debug) DEBUG=1; OPTIONS= ;;
esac

export DEBUG

if [ -n "$DEBUG" ]; then
    LOG=${MYNAME##*/}.log
    echo "Writing to '$LOG'" >/dev/tty
    exec 9>$LOG
fi



set -- $ARGUMENTS
if [ -n "$DEBUG" ]; then
     echo "ARGUMENTS: $@" 2>&9
     echo "OPTIONS: $@" 2>&9
fi

[ "$1" = nodev ] && shift

if [ $# = 1 ]; then
  mkdir -p "$1"
  MOUNTCMD="$ABSME %r %m"
  #UMOUNTCMD="$ABSME -u %r %m"
#  MOUNTCMD="sshfs -o reconnect %r:/ %m"
 UMOUNTCMD="fusermount -u -z %m"

  [ -n "$DEBUG" ] && { exec 2>/dev/null; set -x; exec 2>&9; }
  exec afuse -o mount_template="$MOUNTCMD",unmount_template="$UMOUNTCMD"${DEBUG:+,debug}${OPTIONS:+,$OPTIONS} "$1"

elif [ $1 = "-u" ]; then
    shift

  MOUNTPOINT="$1/${2%%[:/]*}"
  [ -n "$DEBUG" ] && { exec 2>/dev/null; set -x; exec 2>&9; }
  exec fusermount -u "$MOUNTPOINT"

elif [ $# = 2 ]; then

  MOUNTPOINT="$2"
  SSHSPEC="$1"
 # $1/${2%%[:/]*}"
 case "$SSHSPEC" in
     *@*) SSHUSER=${SSHSPEC%%@*} ;;
     *) SSHUSER=root ;;
esac
 case "$SSHSPEC" in
   *:?*)  ;;
   *) 
       if [ "${SSHUSER}" = "root" ]; then
           SSHSPEC=$SSHSPEC:/
        else
      SSHSPEC=$SSHSPEC:/home/$SSHUSER
  fi
  ;;
  esac

  [ -n "$DEBUG" ] && { exec 2>/dev/null; set -x; exec 2>&9; }
  exec sshfs "$SSHSPEC" "$MOUNTPOINT" -o allow_root,reconnect
else
    echo "Arguments: $@
Usage: 
  ${MYNAME##*/} <mount-point>
    or
  ${MYNAME##*/} <mount-point> [user@]host:[dir]
" 1>&2
  exit 1

fi
