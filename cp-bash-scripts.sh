#!/bin/sh

MYDIR=`dirname "$0" ` 
SQ="'"
DQ='"'

cd "$MYDIR"

[ $# -ge 1 ] ||set --  "$HOME"

type make 2>/dev/null >/dev/null && MAKE="make" || MAKE=":"

for DIR; do 
 (CMD=
	for FILE in bash/bash_*.*sh; do
  BASE=`basename "$FILE"` 
	BASE=${BASE%.*}
   case "$BASE" in
     *_profile) CMD="grep -vE ${DQ}(^\\s*#[^ !]|^\\s*#.*[\\${DQ}'(){}]|^\\s*#.*esac|^\\s*#.*done|^\\s*#.*unset|^\\s*#\s*for\s|^\\s*#.*;;)$DQ <$DQ$FILE$DQ >$DQ$DIR/.${BASE}$DQ${CMD:+; $CMD}" ;;
     *) CMD="cp -f $DQ$FILE$DQ ${DQ}\$DIR/.${BASE}$DQ${CMD:+; $CMD}" ;;
   esac
   CMD="$CMD || exit \$?"

	 if [ "$MAKE" != : ]; then
		 CMD="make $FILE${CMD:+; $CMD}"
	 fi
	 CMD="$CMD && echo ${DQ}Wrote \$SQ\$DIR/.${BASE}\$SQ$DQ 1>&2"
  done
	[ -n "$DEBUG"  ] && echo "+ $CMD" 1>&2
   eval "$CMD" 
	 )
done
