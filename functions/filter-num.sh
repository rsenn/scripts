filter-num() {
 (IFS="
"
  unset ARGS MODE
  push() {
  eval 'shift; '$1'=${'$1':+"$'$1'$S"}$*'
  }
  S=" -and "
  while :; do
    case "$1" in
      -[0-9]) I=${1#-}; shift ;;
      -f) I=${2}; shift 2 ;; -f=*) I=${1#-?=}; shift ;; -f[0-9]*) I=${1#-?}; shift ;;
      
      -eq | -ne | -lt | -le | -gt | -ge)
        push COND "${NEG:+$NEG }\$((N)) $1 $(suffix-num "$2")"
        shift 2
        NEG=""
      ;;
      ">=") push COND "${NEG:+$NEG }\$((N)) -ge $(suffix-num "$2")"; NEG=""; shift ;;
      "<=") push COND "${NEG:+$NEG }\$((N)) -le $(suffix-num "$2")"; NEG=""; shift ;;
      "=="* | "=") push COND "\$((N)) -eq $(suffix-num "$2")"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $(suffix-num "$2")"; NEG=""; shift ;;
      ">") push COND "${NEG:+$NEG }\$((N)) -gt $(suffix-num "$2")"; NEG=""; shift ;;
      "<") push COND "${NEG:+$NEG }\$((N)) -lt $(suffix-num "$2")"; NEG=""; shift ;;
      
      ">="*) push COND "${NEG:+$NEG }\$((N)) -ge $(suffix-num "${1#??}")"; NEG=""; shift ;;
      "<="*) push COND "${NEG:+$NEG }\$((N)) -le $(suffix-num "${1#??}")"; NEG=""; shift ;;
      "=="* | "="*) push COND "\$((N)) -eq $(suffix-num "${1#*=}")"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $(suffix-num "${1#??}")"; NEG=""; shift ;;
      ">"*) push COND "${NEG:+$NEG }\$((N)) -gt $(suffix-num "${1#?}")"; NEG=""; shift ;;
      "<"*) push COND "${NEG:+$NEG }\$((N)) -lt $(suffix-num "${1#?}")"; NEG=""; shift ;;
      
      -o | -or | --or | "||") S=" -o "; shift ;;
      -a | -and | --and | "||") S=" -a "; shift ;;
      '!')
        NEG='! '
        shift ;;
      *) break ;;
    esac
  done
  : ${I:=1}
  CMD=
  for N in $(seq 1 $((I+1))); do
    CMD="${CMD:+$CMD }\${F$N}"
    FIELDS="${FIELDS:+$FIELDS }F$N"
  done
  CMD="echo \"$CMD\""
  CMD="[ $COND ] && $CMD"
    
  CMD="while read -r $FIELDS; do N=\$F$I; $CMD; done"
  CMD='IFS=" 	"; '$CMD
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}