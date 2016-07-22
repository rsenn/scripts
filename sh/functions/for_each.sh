for_each() {
<<<<<<< HEAD
  ABORT_COND=' return $?'
=======
  unset RVAL
  ABORT_COND=' return ${RVAL-$?}'
>>>>>>> 51c4e37a1ee33369020bc49e1bedea910735802b
  while :; do 
    case "$1" in
      -c | --cd | --ch*dir*) CHANGE_DIR=true; shift ;;
      -f | --force) ABORT_COND=' :'; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
<<<<<<< HEAD
  ABORT_COND=' { unset CMD CHANGE_DIR ABORT_COND DEBUG;  [ "$PD" != "$PWD" ] && cd "$PD" >/dev/null; '$ABORT_COND'; }'
=======
  ABORT_COND=' { RVAL=$?; trap "" INT; unset CMD CHANGE_DIR ABORT_COND DEBUG;  [ "$PD" != "$PWD" ] && cd "$PD" >/dev/null; '$ABORT_COND'; }'
  [ "$CHANGE_DIR" = true ] && trap "$ABORT_COND" INT
>>>>>>> 51c4e37a1ee33369020bc49e1bedea910735802b
  PD=$PWD
  CMD=$1
  if [ "$(type -t "$CMD")" = function ]; then
    CMD="$CMD \"\$@\""
  fi
  [ "$DEBUG" = true ] && CMD="echo \"+\${D:+\$D:} $CMD\" 1>&2; $CMD"
  [ "$CHANGE_DIR" = true ] &&  CMD='D=$1; cd "$D" >/dev/null;'$CMD';cd - >/dev/null'  || CMD='D=;'$CMD
  	
  if [ $# -gt 1 ]; then
    CMD='while shift; [ "$#" -gt 0 ]; do { '$CMD'; } ||'$ABORT_COND'; done'
  else
    CMD='while read -r LINE; do set -- $LINE; { '$CMD'; } ||'$ABORT_COND'; done'
  fi
#	[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD; $ABORT_COND"
}
