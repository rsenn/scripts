decompress-7z() {
 (while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#

  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }

  [ $# -le 0 ] && set -- -

  while [ $# -gt 0 ]; do
   (case "$1" in
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
      -) OPTS="${OPTS:+$OPTS }-si" ;;
    esac
    OPTS=${OPTS:+$OPTS }"-so"
    CMD="7z x \$OPTS ${ARCHIVE+\"\$ARCHIVE\"}"
    eval "$CMD" )
    shift
  done)
}
