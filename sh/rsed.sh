#!/bin/sh
#
# rsed.sh: a wrapper around ${SED-sed}(1) recursively iterating over directories
#
# $Id: rsed.sh 575 2008-08-26 12:07:20Z enki $
# ---------------------------------------------------------------------------

addprefix() {
 (PREFIX=$1; shift
  CMD='echo "$PREFIX$LINE"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}
debug()
{
    [ "$DEBUG" = true ] && echo "DEBUG: $@" 1>&2
}
map()
{
    from=$1 to=$2;
    shift;
    while shift && [ "$#" -gt 0 ]; do
        if var_isset "$from$1"; then
            var_set "$to$1" "`var_get "$from$1"`";
        fi;
    done;
    unset -v from to
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}

# rsed [options] [files...]
#
# A recursive '${SED-sed}'.
# ---------------------------------------------------------------------------
rsed()
{
 (IFS="
"
  unset OPTIONS EXPRESSIONS
  
  while [ "$#" -gt 0 ]; do
    case "$1" in
            -x | --debug) DEBUG=true  ;;
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

  set -- ${SED-sed} $OPTIONS `addprefix "-e$IFS" $EXPRESSIONS` "$@"
  [ "$DEBUG" = true ] && set -x

  "$@"
  )
}


if [ "${0##*/}" = rsed.sh ]; then
				rsed "$@" 
fi
