dump-shortcuts() { 
 (while :; do
   case "$1" in
    -*) pushv OPTS "$1"; shift ;;
     *) break ;;
   esac
  done
  for_each 'readshortcut $OPTS -t -r "$1" | sed "N ;; s%\s*\n\s*% % ;; s%^%$1: %"' "$@"
 )
}
