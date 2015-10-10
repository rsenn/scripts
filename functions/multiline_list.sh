multiline-list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}
