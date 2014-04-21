#!/bin/bash

MYDIR=`dirname "$0"` 

cd "$MYDIR"

ABSDIR="$PWD"

get-lan-ip()
{
 ifconfig |sed -n '/127\.0/! s,^[^0-9]*:\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*,\1,p'
}

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

	set -- $DIRS  $(df -a | sed 1d | sed -n 's|.* /m|m|p')


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
							(set -x; mount -o bind /$MNT $MNT)
    ;;
esac
  done
 )
}


bind-mounts "$@" || exit $? 

IP=`get-lan-ip`

if ! grep -q "$IP" etc/hosts; then
  HOSTNAME=`hostname -f`
	echo -e "
# Added by `basename "$0" .sh`:
$IP\\t${HOSTNAME}\\t${HOSTNAME%%.*}" >>etc/hosts
fi
touch etc/resolv.conf

if ! grep -q "^\\s*nameserver" etc/resolv.conf; then
  echo "
# Added by `basename "$0" .sh`:
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 4.2.2.1" >>etc/resolv.conf
fi

IP=`get-lan-ip`

if ! grep -q "$IP" etc/hosts; then
  HOSTNAME=`hostname -f`
	echo -e "
# Added by `basename "$0" .sh`:
$IP\\t${HOSTNAME}\\t${HOSTNAME%%.*}" >>etc/hosts
fi
touch etc/resolv.conf

if ! grep -q "^\\s*nameserver" etc/resolv.conf; then
  echo "
# Added by `basename "$0" .sh`:
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 4.2.2.1" >>etc/resolv.conf
fi

if :; then #[ -h etc/mtab -o ! -s etc/mtab ]; then
				rm -vf etc/mtab
        
				(IFS=" "; while read -r DEV MNT TYPE OPTS A  B; do 

case "$MNT" in
				"$ABSDIR"/*) NEWDIR=${MNT#$ABSDIR} ; echo "$MNT -> $NEWDIR" 1>&2 ; MNT=$NEWDIR ;; 
esac

test -d "${MNT#/}" &&
				printf "%-10s %-10s %-10s %-20s %d %d\n" "$DEV" "$MNT" "$TYPE" "$OPTS" $((A)) $((B))

done) </proc/mounts >etc/mtab

fi


env - PATH="$PATH:/usr/local/bin" TERM="$TERM" DISPLAY="$DISPLAY" HOME="/root"  HOSTNAME="${PWD##*/}" chroot . /bin/bash --login



bind-mounts -u "$@"
