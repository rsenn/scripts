filter-test() {
 (IFS="
" EXCLAM='! '
  unset ARGS NEG
  while :; do
    case "$1" in
      -X | --debug) DEBUG=true; shift ;;
      -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s | -u | -w | -x)
          ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}$1 \"\$LINE\""; shift; unset NEG ;;
      -E) ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}-f \"\$LINE\" -a ${NEG-$EXCLAM}-s \"\$LINE\""; shift; unset NEG ;;
      -a | -o) ARGS="${ARGS:+$ARGS }$1"; shift; unset NEG ;;
      '!') [ "${NEG-false}" = false ] && NEG="" || unset NEG; shift ;;
      *) break ;;
    esac
  done
#  [ -z "$ARGS" ] && exit 2
#  IFS=" "
#  set -- $ARGS
#  IFS="
#" ARGN=$#; ARGS="$*"
  CMD='while read -r LINE; do
  [ '$ARGS' ] && echo "$LINE"
done'

  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}
