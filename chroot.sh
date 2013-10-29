#!/bin/sh

MYDIR=`dirname "$0"` 

cd "$MYDIR"

bind-mounts()
{
 (IFS="
 "; while :; do
    case "$1" in 
      -u | --undo) UNDO=true; shift ;;
      *) break ;;
    esac
  done

  DIRS="dev/pts dev sys proc tmp"

  set -- $DIRS

  for MNT; do
    umount -f $MNT 2>/dev/null
  done

  if [ "$UNDO" = true ]; then
    return 1
  fi
  
  for MNT; do
    mount -o bind /$MNT $MNT
  done
 )
}


bind-mounts "$@" || exit $? 

env HOME="/root"  HOSTNAME="${PWD##*/}" chroot . /bin/bash --login

bind-mounts -u "$@"
