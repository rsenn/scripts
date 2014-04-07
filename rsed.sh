#!/bin/sh
#
# rsed.sh: a wrapper around sed(1) recursively iterating over directories
#
# $Id: rsed.sh 575 2008-08-26 12:07:20Z enki $
# ---------------------------------------------------------------------------

pushv () 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

# rsed [options] [files...]
#
# A recursive 'sed'.
# ---------------------------------------------------------------------------
rsed()
{
 (IFS="
"
  unset OPTIONS EXPRESSIONS
  
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e) 
        pushv EXPRESSIONS "$2"
        shift
      ;;
      -e*)
        pushv EXPRESSIONS "${1#-e}"
      ;;
      -*)
        pushv OPTIONS "$1" 
      ;;
      *)
        if test "${EXPRESSIONS+set}" != set; then
          EXPRESSIONS="$1"
          shift
        fi
        break
      ;;
    esac
    shift
  done

  # if some of the remaining arguments are directories we have to search them.
  if some 'test -d "$1"' "$@"; then
    set -- `map 'fs_recurse -f "$1"' "$@"`
  fi

  sed $OPTIONS `addprefix "-e$IFS" $EXPRESSIONS` "$@"
  )
}

