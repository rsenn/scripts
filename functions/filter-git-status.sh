filter-git-status()
{
 (unset MATCH SUBST MODIFIER
  while :; do
    case "$1" in
      -v) MODIFIER='!'; shift ;;
    *) break ;;
    esac
  done
  WHAT=${1:-untracked}
  shift
  ARGS="-n"
  case "$WHAT" in
    untr*|unkn*) PATTERN='??' ;;
    ign*) PATTERN='!!' ;;
    add*|new*) PATTERN='.\?A' ;;
    modif*|change*) PATTERN='.\?M' ;;
    delete*|remov*) PATTERN='.\?D' ;;
    rena*) PATTERN='.\?R' ;;
    cop[iy]*) PATTERN='.\?C' ;;
    unmerg*|upda*) PATTERN='.\?U' ;;
    #*) echo "No such git status specifier: $WHAT" 1>&2; exit 1 ;;
  esac
  : ${MATCH="\\|^$PATTERN|"}
  : ${SUBST="s|^...||p"}
  exec sed $ARGS "${MATCH:+$MATCH$MODIFIER} { $SUBST }")
}
