dump-shortcuts() {
 (while :; do
   case "$1" in
    -*) pushv OPTS "$1"; shift ;;
     *) break ;;
   esac
  done
  for-each 'readshortcut $OPTS -t -r "$1" | ${SED-sed} "N ; s%\s*
\s*% % ; s%^%$1: %"' "$@"
 )
}
