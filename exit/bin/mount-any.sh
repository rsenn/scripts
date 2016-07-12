#!/bin/bash

: ${MNTDIR:="$HOME/mnt"}

while :; do
  case "$1" in
      -t) TYPE="$2" ; shift 2 ;;
      -t*) TYPE="${1#-t}" ; shift  ;;
    *) break ;;
  esac
done


for ARG; do
  FILE=${ARG##*/}
  NAME=${FILE%.iso}
  MNT="$MNTDIR/$NAME"

  umount "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"

  if [ ! -b "$ARG" -a ! -c "$ARG" ]; then

      mount ${TYPE:+-t "$TYPE"} -o loop "$ARG" "$MNT" || exit $?
  else
      mount "$ARG" "$MNT" || exit $?
  fi
done
