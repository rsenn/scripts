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
    *,debug | *,debug,* | debug,*) DEBUG=1 ;;
esac

export DEBUG

if [ -n "$DEBUG" ]; then
    LOG=${MYNAME##*/}.log
    echo "Writing to '$LOG'" >/dev/tty
    exec 9>$LOG
fi



set -- $ARGUMENTS
  [ -n "$DEBUG" ] && echo "ARGUMENTS: $@" 1>&9

[ "$1" = nodev ] && shift

if [ $# = 1 ]; then
  mkdir -p "$1"
  MOUNTCMD="$ABSME %r %m"
  #UMOUNTCMD="$ABSME -u %r %m"
#  MOUNTCMD="sshfs -o reconnect %r:/ %m"
 UMOUNTCMD="fusermount -u -z %m"

  [ -n "$DEBUG" ] && set -x && exec 2>&9 
  exec afuse -o mount_template="$MOUNTCMD",unmount_template="$UMOUNTCMD",allow_root${DEBUG:+,debug} "$1"

elif [ $1 = "-u" ]; then
    shift

  MOUNTPOINT="$1/${2%%[:/]*}"
  [ -n "$DEBUG" ] && set -x && exec 2>&9
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

  [ -n "$DEBUG" ] && set -x && exec 2>&9
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
