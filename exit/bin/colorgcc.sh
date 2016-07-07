#!/bin/sh

MYNAME=`basename "$0" .sh`
MYDIR=`dirname "$0"`

COMPILER=${MYDIR}/${MYNAME#color*-}

COLOR_RED="[1;31m"
COLOR_GREEN="[1;32m"
COLOR_YELLOW="[1;33m"
COLOR_BLUE="[1;34m"
COLOR_MAGENTA="[1;35m"
COLOR_NONE="[0m"

colorize() {
	eval "shift; echo \"\${COLOR_$1}\$*\${COLOR_NONE}\""
}

#set -x
exec "$COMPILER" "$@" 2>&1 | while read -r MESSAGE; do

	FILE=${MESSAGE%%:*}
	LINE=${MESSAGE#$FILE:}
	LINE=${LINE%%:*}

  case "$MESSAGE" in
		*:*:" warning: "*) 
			WARNING=${MESSAGE#*:*": warning: "}

			echo "`colorize YELLOW $FILE`:`colorize GREEN $LINE`: warning: $WARNING"
	  ;;

		*:*:" error: "*)
      ERROR=${MESSAGE#*:*": error: "}

			echo "`colorize YELLOW $FILE`:`colorize GREEN $LINE`: error: $ERROR"
			;;
		*) echo "$MESSAGE" ;;
	esac
done
