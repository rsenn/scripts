#!/bin/bash

MNTDIR="$HOME/mnt"
: ${FUSEISO=`which fuseiso`}

for ARG; do
 (FILE=${ARG##*/}
  NAME=${FILE%.iso}
  TYPE=`file "$ARG"`

  case "$TYPE" in
    *UDF*) unset FUSEISO ;;
  esac
  : ${USER_ID:=`id -u`}

  MNT="$MNTDIR/$NAME"

  fusermount -u "$MNT" 2>/dev/null
  
  mkdir -p "$MNT"

  if [ "$FUSEISO" ]; then
    fuseiso "$ARG" "$MNT" -o allow_other  || exit $?
  else
    if [ "$USER_ID" != 0 ]; then
      SUDO="sudo"
    fi

    $SUDO mount -o loop${USER_ID:+,uid=$USER_ID} "$ARG" "$MNT" || exit $?
  fi)
done
