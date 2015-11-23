#!/bin/sh

addprefix()
{
 (PREFIX=$1; shift
  CMD='echo "$PREFIX$LINE"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}

addsuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "$LINE$SUFFIX"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}

cut_dirname()
{
    sed "s,\\(.*\\)[/\\\\]\\([^/\\\\]\\+[/\\\\]\\?\\)${1//./\\.}\$,\2,"
}

removesuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "${LINE%$SUFFIX}"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}


eval "extract-urls.sh http://sourceforge.net/p/cygwin-ports/_list/git?page="{`seq -s, 0 27`}  2>/dev/null |
   grep '/p/cygwin-ports/[^/]\+/$'|
   removesuffix /|cut_dirname |
   addprefix git://git.code.sf.net/p/cygwin-ports/ |
   addsuffix .git
