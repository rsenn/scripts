#!/bin/sh


while :; do

  case "$1" in
    -r | --recursive) RECURSIVE=true; shift ;;
  *) break ;;
  esac

done

unset SYMLINKS


while [ "$1" ]; do
  ARG="$1"
  shift
  if test -d "$ARG" -a "$RECURSIVE" = true ; then
    ARG=` find "$ARG" -type l` 
    set -- $ARG "$@"
    continue
  fi

  test -h "$ARG" || continue

  SYMLINKS="${SYMLINKS:+$SYMLINKS
}$ARG"

done

for SYMLINK in $SYMLINKS; do
  DIR=`dirname "$SYMLINK"` 
  BASE=`basename "$SYMLINK"` 

( cd "$DIR"
  TARGET=` readlink "$BASE" `

 test -e "$TARGET"  || echo "Target '$TARGET' of symlink "$SYMLINK" not found!" 1>&2
  )
done


