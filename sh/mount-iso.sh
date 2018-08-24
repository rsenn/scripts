#!/bin/bash

MNTDIR="$HOME/mnt"
: ${FUSEISO=`which fuseiso`}

for ARG; do
  FILE=${ARG##*/}
  NAME=${FILE%.iso}


  MNT="$MNTDIR/$NAME"

  fusermount -u "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"

  if [ "$FUSEISO" ]; then
    fuseiso "$ARG" "$MNT" -o allow_other  || exit $?
  else
    mount -o loop "$ARG" "$MNT" || exit $?
  fi
done
