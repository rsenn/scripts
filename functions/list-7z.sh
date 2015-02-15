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
   (B=${1##*/}
    case "$1" in 
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
    esac
    case "$1" in 
      *.t?z | *.tbz2)
        T=${1%.t?z}
        T=${T%.tbz2} 
        T=$T.tar
        INPUT="${INPUT:+$INPUT | }7z x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${T}";  CMD="7z l -slt $OPTS"
        ;;
      *.tar.*) INPUT="${INPUT:+$INPUT | }7z x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${B%.*}";  CMD="7z l -slt $OPTS" ;;
      *) CMD="7z l -slt $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si${1##*/}"
    fi 
    ( #echo "CMD: $CMD" 1>&2 
     eval "($CMD) 2>/dev/null" ) | 
    { IFS=" "; unset PREV; while read -r NAME EQ VALUE; do
        case "$NAME" in
          Path) F=${VALUE//"\\"/"/"} ;;
          Folder) [ "$VALUE" = + ] && FP="/"       ;;
          *) ;;
        esac
        [ -z "$NAME" ] && unset F FP
        if [ -n "$F$FP" -a "$F$FP" != "$PREV" ]; then
          output "$F$FP"
          PREV="$F$FP"
        fi
      done
    }
    )
    shift
  done)
}
