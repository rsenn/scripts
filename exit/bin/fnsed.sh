#!/bin/bash

IFS="
"
while :; do
  case "$1" in
    -r) RECURSIVE=true; shift ;;
    -e) EXPRESSION="${EXPRESSION:+$EXPRESSION
}$1";  shift ;;
    *) break ;;
  esac
done

if test -z "$EXPRESSION"; then
  EXPRESSION="$1"
  shift
fi

FILES="$*"

EXPRESSION=`echo "$EXPRESSION" | ${SED-sed} "s,\*,[^/]\*,g"`

if ${RECURSIVE:-false}; then
  find ${FILES:-*} -not -type d
else
  [ "$FILES" ] && echo "$FILES"
fi |
while read -r FILENAME; do
  BASE=`basename "$FILENAME"`
  DIR=`dirname "$FILENAME"`

 # FILENAME=`echo "$FILENAME" | ${SED-sed} "s,\",\\\\\",g ;; s,',\\\\',g ;; s,\$,\\\\\$,g"`
  
  #echo "mv -vf $FILENAME ${DIR:-.}/${BASE}"
  SUBST=`echo "$BASE" | ${SED-sed} -u "$EXPRESSION"`

  if [ "$BASE" != "$SUBST" ]; then
    (set -x
     mv -vf "$FILENAME" "${DIR:-.}/${SUBST}"
    )
  fi
done 

