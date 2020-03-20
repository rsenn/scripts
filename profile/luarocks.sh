alias luarocks=_luarocks

_luarocks() {
 (CMD="$1"
  FILTER=""
  case "$CMD" in
    search)  FILTER="${FILTER:+$FILTER ;; } /^[-=\\s]\+\$/d ;; /^\$/d ;; /^   [^ ]/d ;; /Search results for/d ;; /Rockspecs and source rocks:/d"    ;;
  esac
  shift
  for ARG; do 
    eval "(echo 'Searching $ARG ...' 1>&2 ; set -x; command luarocks \$CMD \$ARG${FILTER:+ | sed -e '$FILTER'}) || exit \$?"
  done)
}
