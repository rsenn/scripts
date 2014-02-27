#!/bin/bash
#[ $# -eq 1 ] && { INPUT="$1"; GREPFLAGS="-H"; } || {
#TMP=$(mktemp)
#INPUT="$TMP"
#(set -x; grep -H ".*" "${@:-files.list}" |sed -u "s,/files.list:,/,") >"$TMP"
#wc -l "$TMP" 1>&2
#GREPFLAGS="-h"
#}
#
#grep $GREPFLAGS "/\$"  "$INPUT"  |Awhile read -r DIR; do
DO_COUNT_INDIR=true
DO_COUNT_RECURSIVE=true

while :; do
				case "$1" in
								  -D | --no-count-indir*) DO_COUNT_INDIR="false" ; shift ;;
								  -R | --no-coun-recur*) DO_COUNT_RECURSIVE="false" ; shift ;;
					--maxdepth=*) MAXDEPTH=${1#*=}; shift ;; --maxdepth) MAXDEPTH=${2}; shift 2 ;;
					--mindepth=*) MINDEPTH=${1#*=}; shift ;; --mindepth) MINDEPTH=${2}; shift 2 ;;
								  --input-dirs) INPUT_DIRS="$2" ; shift 2 ;;
								  --input-dirs=*) INPUT_DIRS="${1#*=}" ; shift  ;;
					*) break ;;
	esac
	done
INPUT="${1-files.list}" 
: ${INPUT_DIRS="$INPUT"}

FMT="%4d"

if [ "$DO_COUNT_INDIR" = true ]; then
	 FMT="$FMT %4d"
fi

if [ "$DO_COUNT_RECURSIVE" = true ]; then
	 FMT="$FMT %4d"
fi
FMT="$FMT %s\\n"

INPUT_CMD='grep "/\$"  "$INPUT"'

[ "$INPUT_DIRS" = - ] && unset INPUT_DIRS

[ "$INPUT_DIRS" != "$INPUT" ] && INPUT_CMD="cat${INPUT_DIRS+ \"\$INPUT_DIRS\"}"
eval "$INPUT_CMD" |
while read -r DIR ; do
  DIR=${DIR#*:}
  DIR=${DIR%/}
 
   DEPTH=$(IFS="/"; set -- $DIR; echo $#)

	  [ -n "$MAXDEPTH" -a "$DEPTH" -gt "$MAXDEPTH" ] && continue
	  [ -n "$MINDEPTH" -a "$DEPTH" -lt "$MINDEPTH" ] && continue

	 set --  $((DEPTH))
 
   if [ "$DO_COUNT_INDIR" = true ]; then
					 COUNT_RECURSIVE=$(grep "^$DIR/[^/][^/]*\$" "$INPUT" |wc -l)
					 set -- "$@" $((COUNT_RECURSIVE))
	 fi

   if [ "$DO_COUNT_RECURSIVE" = true ]; then
					 COUNT_RECURSIVE=$(grep "^$DIR/." "$INPUT" |wc -l)
					 set -- "$@" $((COUNT_RECURSIVE))
	 fi



   printf "$FMT" "$@" "$DIR"
   
done
  
  
  
