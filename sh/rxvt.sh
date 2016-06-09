#!/bin/sh
NL="
"

FN="-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15"
FB="$FN"
IFS="
"
ARGS="$*"

for RXVT in `file {/usr,}/*bin/*rxvt* |grep ':.*executable' |grep -v ':.*script' | cut -d: -f1 | sort -r`; do
	if "$RXVT" -help 2>&1 | ${GREP-grep
-a
--line-buffered
--color=auto} -i -q "Usage:"; then
		break
	fi
done

set -- +sb -rv -fn "$FN" -fb "$FB" -title Terminal -ls -bg gray

[ "$ARGS" ] && set -- "$@" -e $ARGS

exec "$RXVT" "$@"
