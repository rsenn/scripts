#!/bin/sh

MYNAME=${0%.sh}
ABSME=`realpath "$0"`

while :; do
    case "$1" in
        -d | -x | --debug) DEBUG=1; shift ;;
        *) break ;;
    esac
done

export DEBUG

if [ $# = 1 ]; then
  mkdir -p "$1"
  MOUNTCMD="$ABSME %r %m"
  #UMOUNTCMD="$ABSME -u %r %m"
#  MOUNTCMD="sshfs -o reconnect %r:/ %m"
 UMOUNTCMD="fusermount -u -z %m"

  [ ! -z "$DEBUG" ] && set -x
  exec afuse -o mount_template="$MOUNTCMD",unmount_template="$UMOUNTCMD",allow_root${DEBUG:+,debug} "$1"

elif [ $1 = "-u" ]; then
    shift

  MOUNTPOINT="$1/${2%%[:/]*}"
  [ ! -z "$DEBUG" ] && set -x
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

  [ ! -z "$DEBUG" ] && set -x
  exec sshfs "$SSHSPEC" "$MOUNTPOINT" -o allow_root,reconnect
else
    echo "Usage: 
  ${MYNAME##*/} <mount-point>

    or

  ${MYNAME##*/} <mount-point> [user@]host:[dir]
" 1>&2
  exit 1

fi
