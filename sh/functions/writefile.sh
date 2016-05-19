writefile() {
 (while :; do
   case "$1" in
     -a | --append) APPEND=true; shift ;;
     *) break ;;
   esac
  done
  FILE="$1"
  shift
  CMD='for LINE; do echo "$LINE"; done'
  [ "$APPEND" = true ] && CMD="$CMD >>\"\$FILE\"" || CMD="$CMD >\"\$FILE\""
  eval "$CMD")
}
