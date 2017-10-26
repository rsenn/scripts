#!/bin/bash

mount_loop() {
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
    MAGIC=`file - <"$ARG"`; MAGIC=${MAGIC#*": "}
    NAME=${FILE%.iso}
    MNT="$DEST/$NAME"

    echo "MAGIC: $MAGIC" 1>&2

    umount "$MNT" 2>/dev/null
    
    mkdir -p "$MNT"

    if [ ! -b "$ARG" -a ! -c "$ARG" ]; then

        : mount ${TYPE:+-t "$TYPE"} -o loop${OPTS:+",$OPTS"} "$ARG" "$MNT" || exit $?
    else
        : mount "$ARG" "$MNT" || exit $?
    fi
  done
}

case "${0##*/}" in
  -* | sh | bash) ;;
  *) mount_loop "$@" ;;
esac
