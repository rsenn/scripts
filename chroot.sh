#!/bin/bash

MYDIR=`dirname "$0"` 
cd "$MYDIR"
ABSDIR=`pwd`

bind-mounts()
{
 (IFS="
 "; while :; do
    case "$1" in 
      -u | --undo) UNDO=true; shift ;;
      *) break ;;
    esac
  done

  DIRS="dev dev/pts sys proc tmp"
echo "ABSDIR=$ABSDIR" 1>&2
  set -- $DIRS $(df -a 2>/dev/null | sed 1d | sed -n 's|.* /m|m|p' | grep -v "^${ABSDIR#/}")

  for MNT; do
   (umount "$ABSDIR/$MNT" 2>/dev/null ||
		umount -f "$ABSDIR/$MNT" 2>/dev/null || 
		umount -l "$ABSDIR/$MNT" 2>/dev/null) #&& echo "Unmounted $ABSDIR/$MNT" 1>&2
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
      mnt/*/mnt/*) continue ;; 
			*)
        (set -x;  mount -o bind /$MNT "$ABSDIR/$MNT")

    ;;
esac
  done
 )
}


bind-mounts || exit $? 

cp -vf /etc/resolv.conf etc/

trap 'rm -f "$ABSDIR/chroot.bashrc"' EXIT
cat >chroot.bashrc <<EOF
. root/.bash_profile
. root/.bash_functions
PS1="\033[0m${ABSDIR##*/}@\\h < \w > \\\$ "
cd
EOF

env - PATH="$PATH:/usr/local/bin" TERM="$TERM" DISPLAY="$DISPLAY" HOME="/root"  PS1="\033[0m${ABSDIR##*/}@\\h < \w > \\\$ " \
 HOSTNAME="${PWD##*/}" chroot . ${@:-/bin/bash --init-file chroot.bashrc}

bind-mounts -u "$@"
