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
      -eq | -ne | -lt | -le | -gt | -ge)
        push COND "${NEG:+$NEG }\$((N)) $1 $2"
        shift 2
        NEG=""
      ;;
      ">=") push COND "${NEG:+$NEG }\$((N)) -ge $2"; NEG=""; shift ;;
      "<=") push COND "${NEG:+$NEG }\$((N)) -le $2"; NEG=""; shift ;;
      "=="* | "=") push COND "\$((N)) -eq $2"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $2"; NEG=""; shift ;;
      ">") push COND "${NEG:+$NEG }\$((N)) -gt $2"; NEG=""; shift ;;
      "<") push COND "${NEG:+$NEG }\$((N)) -lt $2"; NEG=""; shift ;;
      
      ">="*) push COND "${NEG:+$NEG }\$((N)) -ge ${1#??}"; NEG=""; shift ;;
      "<="*) push COND "${NEG:+$NEG }\$((N)) -le ${1#??}"; NEG=""; shift ;;
      "=="* | "="*) push COND "\$((N)) -eq ${1#*=}"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne ${1#??}"; NEG=""; shift ;;
      ">"*) push COND "${NEG:+$NEG }\$((N)) -gt ${1#?}"; NEG=""; shift ;;
      "<"*) push COND "${NEG:+$NEG }\$((N)) -lt ${1#?}"; NEG=""; shift ;;
      
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
