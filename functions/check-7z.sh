check-7z() {
 (while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  IFS="
"
  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }
  OUTDIR="$PWD/Check-$RANDOM"
  rm -rf "$OUTDIR"
  mkdir -p "$OUTDIR"
  trap 'rm -rf "$OUTDIR"' EXIT
  FILTER="xargs -n1 -d \"\${IFS:0:1}\" sha1sum"
  #FILTER="$FILTER | ${SED-sed} \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\${ARCHIVE}\${SEP:-: }\\2 \\[\\1\\]|\""
  FILTER="$FILTER | ${SED-sed} \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\\1 \\*\${ARCHIVE}\${SEP:-:}\\2|\""
  process() { IFS="
 "; set +x;
    unset PREV; while read -r LINE; do
    LINE=${LINE//"\\"/"/"}
     case "$LINE" in
     "Extracting: "*) ARCHIVE=${LINE#"Extracting: "}; echo "Archive=${ARCHIVE}" 1>&2; continue ;;
      "Extracting  "*)
          FILE=${LINE#"Extracting  "}
          if [ -n "$FILE" -a "$FILE" != "$PREV" ]; then
#				    echo "FILE='$FILE'" 1>&2
          [ "$FILE" = "$T" ] && continue
            if [ -e "$FILE" ]; then [ -f "$FILE" ] && echo "$FILE"
            else echo "File '$FILE' not found!" 1>&2; fi
          fi
        PREV="$FILE" ;;
     esac; done
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
        INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${T}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS"
        ;;
      *.tar.*) T=${1%.tar*}.tar;
      INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${B%.*}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS" ;;
      *) CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" -y $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    T=${T##*/}
    	    #echo "T='$T'" 1>&2
      if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si${1##*/}"
    fi
      CMD="($CMD) 2>&1 | (cd \"\$OUTDIR\" >/dev/null; process${FILTER:+ | $FILTER})"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
     eval "$CMD") || exit $?
    shift
  done)
}
