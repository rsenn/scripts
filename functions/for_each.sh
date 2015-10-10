for_each() {
  CMD=$1
  if [ "$(type -t "$CMD")" = function ]; then
    CMD="$CMD \"\$@\""
  fi
  [ "$DEBUG" = true ] && CMD="echo \"+ $CMD\" 1>&2; $CMD"
  if [ $# -gt 1 ]; then
    CMD='while shift; [ "$#" -gt 0 ]; do { '$CMD'; } || return $?; done'
  else
    CMD='while read -r LINE; do set -- $LINE; { '$CMD'; } || return $?; done'
  fi
#	[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD"
  unset CMD
}
