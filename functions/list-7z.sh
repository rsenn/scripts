list-7z() {
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

  while [ $# -gt 0 ]; do
   (case "$1" in 
      *://*) INPUT="curl -s \"\$1\"" ;;

    *) ARCHIVE=$1  ;;
    esac
    CMD="7z l -slt \$OPTS ${ARCHIVE+\"\$ARCHIVE\"}"
    if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si${1##*/}"
    fi 
    eval "$CMD" | 
    { IFS=" "; unset PREV; while read -r NAME EQ VALUE; do
        case "$NAME" in
          Path) F=${VALUE//"\\"/"/"} ;;
          Folder) [ "$VALUE" = + ] && FP="/"       ;;
          *) ;;
        esac
        test -z "$NAME" && unset F FP
        if test -n "$F$FP" -a "$F$FP" != "$PREV"; then
          output "$F$FP"
          PREV="$F$FP"
        fi
      done
    }
    )
    shift
  done)
}
