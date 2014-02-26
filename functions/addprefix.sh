addprefix()
{ 
 (PREFIX=$1; shift
  CMD='echo "$PREFIX$LINE"'
  if [ $# -gt 1 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}
