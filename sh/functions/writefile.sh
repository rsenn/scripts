writefile() {
 (while :; do
   case "$1" in
     -a | --append) APPEND=true; shift ;;
     -t | --temp) TEMP=`mktemp`; trap 'rm -f "$TEMP"' EXIT; shift ;;
     *) break ;;
   esac
  done
  FILE="$1"
  shift
  CMD='echo "$LINE"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else 
    CMD="while read -r LINE; do $CMD; done"
  fi
   
  [ "$APPEND" = true ] && CMD="$CMD >>\"\${TEMP-FILE}\"" || CMD="$CMD >\"\${TEMP-FILE}\""
  if [ "${TEMP+set}" = set ]; then
    CMD="$CMD; mv -f -- \"\$TEMP\" \"\$FILE\""
  fi
  eval "$CMD")
}
