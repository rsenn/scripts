cut-num() {
 (unset N
 while :; do
    case "$1" in
      -n | --num) N="$2"; shift 2 ;;
      -n=* | --num=*) N="${1##*=}"; shift ;;
      -n) N="${1#-n}"; shift ;;
      *) break ;;
    esac
  done
  : ${N=1}
  EXPR=
  while [ $((N)) -gt 0 ]; do
    EXPR="$EXPR[0-9]\\+\\s*"
    : $((N--))
  done
  ${SED-sed} "s|^${EXPR:+\\s*$EXPR}||" "$@")
}
