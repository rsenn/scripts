#!/bin/sh
IFS="
"

while :; do

  case "$1" in
    -p | --print) PRINT=true; shift ;;
    -r | --recursive) RECURSIVE=true; shift ;;
    -d | --delete) DELETE=true; shift ;;
    -s | --simple) SIMPLE=true; shift ;;
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
}${ARG#./}"

done

for SYMLINK in $SYMLINKS; do
  DIR=`dirname "$SYMLINK"` 
  BASE=`basename "$SYMLINK"` 

( cd "$DIR"
  TARGET=` readlink "$BASE" `

 if [ "$PRINT" = true ]; then
   case "$TARGET" in
       /*) echo "$TARGET" ;;
     *) echo "$DIR/$TARGET" ;;
   esac
 fi
 if [ ! -e "$TARGET" ]; then
   if [ "$DELETE" = true ]; then 
     rm -vf "$BASE"
   else
    if [ "$SIMPLE" = true ]; then
		 echo "$SYMLINK" 1>&2
		else
		 echo "Target '$TARGET' of symlink "$SYMLINK" not found!" 1>&2
	 fi
	 fi

 fi
  )
done


