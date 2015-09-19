list-rar() {
 (while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  fi
  }
  for ARG; do
   (IFS="/\\"
    LINENO=0
    HEADER_OK="false"
    unrar v "$ARG" | while read -r LINE; do
      LINENO=$((LINENO + 1))
      case "$LINE" in
        -------------------------------------------------------------------------------*)
          HEADER_OK="true"
          continue
        ;;
        "  "*)
          continue
        ;;
      esac
      "$HEADER_OK" || continue
        
      LINE=${LINE#" "}
      LINE=${LINE%$'\r'}
      #LINE=${LINE//"\\"/"/"}
      
      output $LINE
    done)
  done)
}
