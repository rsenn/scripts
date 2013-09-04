#!/bin/sh
SVNWORK=
SVNPATH=

if [ -d .svn -a -r .svn/entries ]; then
  SVNWORK="$PWD/.svn/entries"
  SVNPATH=`sed -n "5 { /:\/\// { p; q; } }" .svn/entries`
fi

if [ -z "$SVNWORK" ]; then
  echo "Not a subversion working directory." 1>&2
  exit 2
elif [ -z "$SVNPATH" ]; then
  echo "Could not determine SVN path from $SVNWORK" 1>&2
  exit 3
fi

echo "$SVNPATH"
