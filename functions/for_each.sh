for_each() {
  ABORT_COND=' || return $?'
  while :; do 
    case "$1" in
      -f | --force) ABORT_COND=; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  CMD=$1
  if [ "$(type -t "$CMD")" = function ]; then
    CMD="$CMD \"\$@\""
  fi
  [ "$DEBUG" = true ] && CMD="echo \"+ $CMD\" 1>&2; $CMD"
 
  	
  if [ $# -gt 1 ]; then
    CMD='while shift; [ "$#" -gt 0 ]; do { '$CMD'; }'$ABORT_COND'; done'
  else
    CMD='while read -r LINE; do set -- $LINE; { '$CMD'; }'$ABORT_COND'; done'
  fi
#	[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD"
  unset CMD
}
