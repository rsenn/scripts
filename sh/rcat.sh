#!/bin/sh
NL="
"
#
# rcat.sh: 
#
# $Id: rcat.sh 538 2008-08-18 19:20:49Z enki $
# -------------------------------------------------------------------------
pushv() 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

# rcat [options] [files...]
#
# A recursive 'cat' through ${GREP-grep
-a
--line-buffered
--color=auto} .*
# ---------------------------------------------------------------------------
rcat()
{
 (IFS="
"; OPTS= ARGS=
  while [ -n "$1" ]; do
    case $1 in
      *) pushv ARGS "$1" ;;
      -*) pushv OPTS "$1" ;;
    esac
    shift
  done
  ${GREP-grep
-a
--line-buffered
--color=auto} --color=no $OPTS '^' $ARGS)
}


rcat "$@"
