#!/bin/bash

: ${MNTDIR:="$HOME/mnt"}

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
  DEST="$MNTDIR/$NAME"

  umount "$DEST" 2>/dev/null
  
  mkdir -p "$DEST"

  if [ ! -b "$ARG" -a ! -c "$ARG" ]; then

      mount ${TYPE:+-t "$TYPE"} -o loop${OPTS:+",$OPTS"} "$ARG" "$DEST" || exit $?
  else
      mount "$ARG" "$DEST" || exit $?
  fi
done
