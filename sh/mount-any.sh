#!/bin/bash

: ${DEST:="$HOME/mnt"}

while :; do
  case "$1" in
      -d) DEST="$2" ; shift 2 ;; -d*) DEST="${1#-d}" ; shift  ;;
      -o) OPTS="$2" ; shift 2 ;; -o*) OPTS="${1#-o}" ; shift  ;;
      -t) TYPE="$2" ; shift 2 ;; -t*) TYPE="${1#-t}" ; shift  ;;
    *) break ;;
  esac
done


for ARG; do
  FILE=${ARG##*/}
  NAME=${FILE%.iso}
  MNT="$DEST/$NAME"

  umount "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"

  if [ ! -b "$ARG" -a ! -c "$ARG" -a -e "$ARG" ]; then

     MAGIC=`file "$ARG" | sed "s|$ARG:\s*||"`
     case "$MAGIC" in
       *ISO\ 9660*) fuseiso "$ARG" "$MNT" ${OPTS:+-o "$OPTS"} ;; 
       *Zip\ archive*) fuse-zip "$ARG" "$MNT" ${OPTS:+-o "$OPTS"} ;; 
       *archive* | *compressed*) archivemount "$ARG" "$MNT" ;;
       *) mount ${TYPE:+-t "$TYPE"} -o loop${OPTS:+",$OPTS"} "$ARG" "$MNT" ;;
     esac || 
    exit $?
  else
      mount "$ARG" "$MNT" || exit $?
  fi
done
