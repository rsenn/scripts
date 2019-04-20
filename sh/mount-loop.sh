#!/bin/bash

mount_loop() {

  debug() {
    ${DEBUG:-false} && echo "DEBUG: $@" 1>&2
  }
  unset DEST OPTS TYPE
  while :; do
    case "$1" in
        --debug | -x) DEBUG=:; shift ;;
        -d) DEST="$2" ; shift 2 ;; -d*) DEST="${1#-d}" ; shift  ;;
        -o) OPTS="$2" ; shift 2 ;; -o*) OPTS="${1#-o}" ; shift  ;;
        -t) TYPE="$2" ; shift 2 ;; -t*) TYPE="${1#-t}" ; shift  ;;
      *) break ;;
    esac
  done
  : ${DEST:="$HOME/mnt"}

  for ARG; do
   (FILE=${ARG##*/}
    MAGIC=`file - <"$ARG"`; MAGIC=${MAGIC#*": "}
    NAME=${FILE%.*}
    MNT="$DEST/$NAME"

    echo "MAGIC: $MAGIC" 1>&2
    case "$MAGIC" in
      *Zip*archive*)            MOUNTCMD='fuse-zip "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;; 
      *ISO\ 9660*)              MOUNTCMD='fuseiso "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;;
      *FAT\ *)                  MOUNTCMD='fusefat "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;;
      *ext[234]\ filesystem\ *) MOUNTCMD='fuseext2 "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;;
      *archive\ *)              MOUNTCMD='archivemount "$ARG" "$MNT" ${OPTS:+-o "$OPTS"}' ;;
      *)                        MOUNTCMD='mount ${TYPE:+-t "$TYPE"} "$ARG" "$MNT" -o loop${OPTS:+",$OPTS"}' ;;

    esac

    debug "MOUNTCMD: $MOUNTCMD"
    [ "$DEBUG" = : ] && MOUNTCMD="(set -x; $MOUNTCMD)"

    umount "$MNT" 2>/dev/null
    
    mkdir -p "$MNT"

    if [ ! -b "$ARG" -a ! -c "$ARG" ]; then
       eval "$MOUNTCMD"
        #: mount ${TYPE:+-t "$TYPE"} -o loop${OPTS:+",$OPTS"} "$ARG" "$MNT" || exit $?
    else
        : mount "$ARG" "$MNT" 
    fi) || return $?
  done
}

case "${0##*/}" in
  -* | sh | bash) ;;
  *) mount_loop "$@" || exit $? ;;
esac
