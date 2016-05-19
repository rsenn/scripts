#!/bin/bash
NL="
"

MYDIR=`dirname "$0"` 
cd "$MYDIR"
ABSDIR=`pwd`
IFS="
"

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
  set -- $DIRS $(df -a 2>/dev/null | ${SED-sed} 1d | ${SED-sed} -n 's|.* /m|m|p' | ${GREP-grep -a --line-buffered --color=auto} -v "^${ABSDIR#/}")

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
        *CDROM* | *cdrom* | *BERRY*) ;;
        proc) mount -t proc proc proc ;;
        sys) mount -t sysfs sysfs sys ;;
        tmp) umount -f tmp 2>/dev/null; rm -rf tmp/* ;;
				#dev/pts) mount -o bind /$MNT $MNT ;;
 #       dev/pts) mount -t devpts devpts  dev/pts -o rw,relatime,mode=600,ptmxmode=000 ;;
      mnt/*/mnt/*) continue ;; 
			mnt/*) continue  ;;
			*)
       T=$(echo "$MNT"|${SED-sed} 's,.*mnt.*mnt.*,,g')

			 test -z "$T" && continue

        (set -x;  mount -o bind /$MNT "$ABSDIR/$MNT")

    ;;
esac
  done
 )
}


bind-mounts || exit $? 

cp -vf /etc/resolv.conf etc/

trap 'rm -f "$ABSDIR/.bashrc"' EXIT
cat >.bashrc <<EOF
. /root/.bash_profile
. /root/.bash_functions
#PS1="\033[0m${ABSDIR##*/}@\\h < \w > \\\$ "
cd
EOF

PS1="chroot%(${MYDIR##*/}){ \$PWD } # "
cat >.bash_prompt <<EOF
$PS1
EOF

#SHELL_ARGS="--login"

#PS1="\033[0m${ABSDIR##*/}@\\h < \w > \\\$ "
env - PATH="$PATH:/usr/local/bin" HOME=/ TERM="$TERM" DISPLAY="$DISPLAY" PS1="$PS1" \
 HOSTNAME="${PWD##*/}" chroot . ${@:-/bin/bash
$SHELL_ARGS}

bind-mounts -u "$@"
