#!/bin/bash

: ${MNTDIR:="$HOME/mnt"}
: ${FUSEISO:=`which fuseiso` }

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

  fusermount -u "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"

  if [ ! -b "$ARG" -a ! -c "$ARG" ]; then

    if [ -n "$FUSEISO" -a -f "$FUSEISO" -a -x "$FUSEISO" ]; then
      fuseiso "$ARG" "$MNT" -o allow_other  || exit $?
    else
      mount ${TYPE:+-t "$TYPE"} -o loop "$ARG" "$MNT" || exit $?
    fi
  else
      mount "$ARG" "$MNT" || exit $?
  fi
done
