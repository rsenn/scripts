#!/bin/bash
IFS="
"
while :; do
	case "$1" in
		 -*) KILLARGS="${KILLARGS+$KILLARGS
}$1"; shift ;;
	 *) break ;;
	esac
done

IFS="|$IFS"

if ps --help | grep -q '\-W'; then
  PSARGS="-aW"
else
  PSARGS="axw"	
fi


if type kill.exe 2>/dev/null >/dev/null; then
				KILL="kill.exe"
				KILLARGS="$KILLARGS
-f"
fi

PSOUT=`${PS-ps} $PSARGS`
PSMATCH=` echo "$PSOUT" | grep -iE "($*)" `
PIDS=` echo "$PSMATCH" | sed -n "/${0##*/}/! s,^[^0-9]*\([0-9]\+\).*,\1,p"`

if [ -z "$PIDS" ]; then
  echo "No matching process ($@)" 1>&2
  exit 2
fi
echo "$PSMATCH"
set -x
exec "${KILL:-kill}" $KILLARGS  $PIDS



