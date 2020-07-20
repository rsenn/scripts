#!/bin/bash

: ${MNT:="$HOME/mnt"}

while :; do
  case "$1" in
      -m|--mntdir) MNT="$2" ; shift 2 ;; -m=*|--mntdir=*) MNT="${1#*=}" ; shift  ;;
      -d|--destdir) DEST="$2" ; shift 2 ;; -d=*|--destdir=*) DEST="${1#*=}" ; shift  ;; -d*) DEST="${1#-?}"; shift ;;
      -o) OPTS="$2" ; shift 2 ;; -o*) OPTS="${1#-o}" ; shift  ;;
      -t) TYPE="$2" ; shift 2 ;; -t*) TYPE="${1#-t}" ; shift  ;;
      -x|--debug) DEBUG=true; shift ;;
    *) break ;;
  esac
done

[ "$UID" = 0 ] && FUSEOPT="allow_other" || FUSEOPT="allow_root"

addopt() {
  old_IFS="$IFS"; IFS=","
  OPTS="${OPTS:+$OPTS,}$*"
  IFS="$old_IFS"; unset old_IFS
}

[ $# -gt 1 ] && unset DEST

for ARG; do
 (FILE=${ARG##*/}
     echo "ARG: $ARG" 1>&2
  NAME=${FILE%.*}; NAME=${NAME%.tar*}
 USER_ID=${UID:-`id -u`}
  MNT="${DEST-$MNT/$NAME}"

  umount "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"
    [ $USER_ID -gt 0 ] && { SUDO=sudo; addopt uid=$USER_ID; }

  if [  -e "$ARG" ]; then

     MAGIC=`file - <"$ARG" | sed "s|^/dev/stdin:\s*|| ; s|$ARG:\s*||"`

     echo "MAGIC: $MAGIC" 1>&2
     case "$MAGIC" in
       *FAT*) TYPE=vfat ;;
       *UDF*) TYPE=udf ;;
       *ISO\ 9660*) TYPE=iso9660 ;;
       *ext4*) TYPE=ext4 ;;
     esac
     case "$MAGIC" in
       *FAT*|*UDF*|*Linux*ext4*) addopt loop; CMD='$SUDO mount ${TYPE:+-t "$TYPE"} ${OPTS:+-o "$OPTS"} "$ARG" "$MNT"' ;;
       *ISO\ 9660*) addopt "$FUSEOPT"; CMD='fuseiso "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;; 
       *Zip\ archive*) addopt "$FUSEOPT"; CMD='fuse-zip "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;; 
       *archive* | *compressed*) addopt "$FUSEOPT"; CMD='archivemount "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;;
       *) addopt loop; CMD='$SUDO mount ${TYPE:+-t "$TYPE"} ${OPTS:+-o "$OPTS"} "$ARG" "$MNT"' ;;
     esac
    CMD="$CMD || exit \$?"
    [ "$DEBUG" = true ] && eval "echo + $CMD" 1>&2
    eval "$CMD"
  else
      $SUDO       mount ${OPTS:-o "$OPTS"} "$ARG" "$MNT" || exit $?
    fi)
done
