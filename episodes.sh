#!/bin/bash

count()
{
echo $#
}
IFS="
"
FILES=$(find "${@-.}" -type f -size +20M)

echo "Found $(count $FILES) files." 1>&2


EPISODES=`echo "$FILES" |sed -n 's,.*[Ss]\([0-9][0-9]\)[Ee]\([0-9][0-9]\).*,S\1E\2,p' |sort -u`

set -- $EPISODES

SEASON="${1%%E*}"
SEASON=${SEASON#S}; SEASON=$((SEASON + 0))

EPISODE="${1##*E}"; EPISODE=$((EPISODE + 0))

MISSING=""

for LIST
do
    S=${LIST%%E*}; S=${S#S}; S=${S#0}; S=$((S + 0))

  [ "$S" -gt "$SEASON" ] && SEASON="$S"

  E=${LIST##*E}; E=${E#0}; E=$((E + 0))

   #var_dump SEASON EPISODE S E 1>&2 
echo "$LIST"

  [ $((S)) -eq $((SEASON)) -a $((E)) -eq $((EPISODE)) ] || {
    echo "Season $SEASON Episode $EPISODE is missing!" 1>&2
  }
  EPISODE=$((E+1))
done

