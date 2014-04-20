#!/bin/bash

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

  set -- $DIRS $(df -a | sed 1d | sed -n 's|.* /m|m|p')

  for MNT; do
    umount -f $MNT 2>/dev/null
  done

  if [ "$UNDO" = true ]; then
    return 1
  fi
  
  for MNT; do
    mkdir -p $MNT
    case "$MNT" in
        proc) mount -t proc proc proc ;;
        sys) mount -t sysfs sysfs sys ;;
        tmp) umount -f tmp 2>/dev/null; rm -rf tmp/* ;;
        dev/pts) mount -t devpts devpts  dev/pts -o rw,relatime,mode=600,ptmxmode=000 ;;
      *)
    mount -o bind /$MNT $MNT
    ;;
esac
  done
 )
}


bind-mounts "$@" || exit $? 

env - PATH="$PATH:/usr/local/bin" TERM="$TERM" DISPLAY="$DISPLAY" HOME="/root"  HOSTNAME="${PWD##*/}" chroot . /bin/bash --login



bind-mounts -u "$@"
