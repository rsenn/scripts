removeprefix()
{
 (PREFIX=$1; shift
  CMD='echo "${LINE#$PREFIX}"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}
