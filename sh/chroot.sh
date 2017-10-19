#!/bin/bash
NL="
"

MYDIR=`dirname "$0"` 
cd "$MYDIR"
ABSDIR=`pwd`
IFS="
"
NL="
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
  set -- $DIRS $(df -a 2>/dev/null | ${SED-sed} 1d | ${SED-sed} -n 's|.* /m|m|p' | ${GREP-grep -a --line-buffered} -v "^${ABSDIR#/}")

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
			#mnt/*) continue  ;;
			*)
       T=$(echo "$MNT"|${SED-sed} 's,.*mnt.*mnt.*,,g')

			 test -z "$T" && continue

        (set -x;  mount -o bind /$MNT "$ABSDIR/$MNT")

		;;
	esac
  done
 
  ROOTDEV=$(sed 's,\s\+,\n,g' /proc/cmdline | sed -n 's,root=,,p')
  ROOTLBL=$(e2label "$ROOTDEV")
  MNT=mnt/"$ROOTLBL"
  mkdir -p "$ABSDIR/$MNT"
  set -x; mount -o bind / "$ABSDIR/$MNT")
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

SHELL_ARGS="--norc
--noprofile"

#PS1="\033[0m${ABSDIR##*/}@\\h < \w > \\\$ "

CHROOT_NAME=${PWD##*/}

eval "CC=\"$(sha1sum <<<"$CHROOT_NAME" | sed 's,\s\+-.*,,; s,\([[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]\),$((0x\1 % 216))\n,g' )\""
C1=${CC%%"$NL"*}; CC=${CC#"$C1$NL"}
C2=${CC%%"$NL"*}; CC=${CC#"$C2$NL"}
C3=${CC%%"$NL"*}; CC=${CC#"$C3$NL"}
C4=${CC%%"$NL"*}; CC=${CC#"$C4$NL"}

MSB=$(( (C1 ^ C2 ) & 0xC0))
C4=$(( (C4 & 0x3F)  | MSB))


echo "$CC"


PS1='\[\033[01;38;5;'$((C1+16))'m\]\u\[\033[0m\]@\[\033[01;38;5;'$((C2+16))'m\]$HOSTNAME\[\033[0m\]:(\[\033[01;38;5;'$((C4+16))'m\]\w\[\033[0m\]) \$ '
env - PATH="$PATH:/usr/local/bin" HOME=/root TERM="$TERM" DISPLAY="$DISPLAY" PS1="$PS1" \
 HOSTNAME="${PWD##*/}" chroot . ${@:-/bin/bash
$SHELL_ARGS}

bind-mounts -u "$@"
