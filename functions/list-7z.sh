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
    { IFS=" "; while read -r NAME EQ VALUE; do
      case "$NAME" in
        Path) F="$VALUE" ;;
        Folder) if [ "$VALUE" = + ]; then
            output "$F/"
          else
            output "$F"
          fi
        ;;
        *) ;;
        esac
        test -z "$NAME" && unset F
      done
    }
    )
    shift
  done)
}
