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
    untracked) MATCH="/^??\\s/" ;;
    merge*) MATCH="/^\\s\\?M/" ;;
    #*) echo "No such git status specifier: $WHAT" 1>&2; exit 1 ;;
  esac
  : ${SUBST="s|^...||p"}
  exec sed $ARGS "${MATCH:+$MATCH$MODIFIER} { $SUBST }")
}
