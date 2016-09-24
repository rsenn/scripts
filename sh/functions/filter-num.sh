filter-num() {
 (IFS=$'\n\t\r '
  unset ARGS MODE
  push() {
  eval 'shift; '$1'=${'$1':+"$'$1'$S"}$*'
  }
  S=" -and "
  while :; do
    case "$1" in
      -[0-9]) I=${1#-}; shift ;;
      -[dt]) S=${2}; shift 2 ;; -[dt]=*) S=${1#-?=}; shift ;; -[dt]*) S=${1#-?}; shift ;;
      -[fk]) I=${2}; shift 2 ;; -[fk]=*) I=${1#-?=}; shift ;; -[fk][0-9]*) I=${1#-?}; shift ;;

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
  : ${S=$' \t\r'}
  : ${I:=1}
  CMDX=
  for N in $(seq 1 $((I+1))); do
    CMDX="${CMDX:+$CMDX\$S}\${F$N}"
    FIELDS="${FIELDS:+$FIELDS }F$N"
  done
  CMDX="echo \"$CMDX\""
  CMDX="[ $COND ] && $CMDX"

  CMDX="N=\$F$I; $CMDX"

  CMD="while read -r $FIELDS; do [ \"\$DEBUG\" = true ] && echo \"$CMDX\" 1>&2; $CMDX; done"
  CMD="IFS=\"\${S-\" 	\"}\"; "$CMD
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "($CMD)")
}
