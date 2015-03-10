list-7z() {
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
  output_line() {
	case "$PREV" in
	  "$DN"/* | "$DN/" | "$DN") ;;
	  *) : echo "$DN/" ;;
	  esac
	#    [ -z "$NAME" ] && unset F FP
	if [ "$FN" = "$PREV/" ]; then
	  PREV="$PREV/"
	fi
	case "$PREV" in
	  */) 
		case "$FN" in
		  $PREV/*) ;; *) unset PREV ;;
		esac
	  ;;
	  esac
	if [ -n "PREV" -a "$FN" != "$PREV" -a "$FN" != "$PPREV" ]; then
	  case "$PREV" in 
	    */) ;;
	    *)
	    DIR="${PREV}"
	      while :; do
	        [ "$DIR" = "${DIR%/*}" ] && break
	        DIR="${DIR%/*}"
	       #echo "DIR='$DIR' PREVDIR='$PREVDIR'" 1>&2
	      if [ -z "$PREVDIR" -o "${PREVDIR#$DIR/}" = "$PREVDIR" ]; then
	       [ -n "$PREVDIR" ] && output "$PREVDIR"
	       PREVDIR="$DIR/"
	      fi
	      
	      case "$DIR" in
	        ${PREVDIR%/}/*) continue ;;
	      esac	      
	      case "${PREVDIR%/}" in
	        ${DIR}/*) continue ;;
	      esac
	      #[ "$DIR/" != "$PREVDIR" ] &&
	        output "$DIR/"
	        case "${PREVDIR%/}" in
	          $DIR | $DIR/*) ;;
	          *) PREVDIR="$DIR/" ;;
	        esac
	      done	    
	     ;;
	  esac
	  output "$PREV"
	fi   
	PPREV="$PREV"
	if [ -n "$FN" -a "$FN" != "$PREV" ]; then
	  #output "$FN"
	  PREV="$FN"
	fi
	case "$PREV" in
	  */) PREVDIR="$PREV" ;;
	esac
	[ -z "$NAME" ] && unset A F FP PSZ SZ T FN
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
        INPUT="${INPUT:+$INPUT | }7z x -si\"${1}\" -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${T}\"";  CMD="7z l -slt $OPTS"
        ;;
      *.tar.*) INPUT="${INPUT:+$INPUT | }7z x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${B%.*}\"";  CMD="7z l -slt $OPTS" ;;
      *) CMD="7z l -slt $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si\"${1##*/}\""
    fi 
    ( #echo "CMD: $CMD" 1>&2 
     eval "($CMD; echo) 2>/dev/null" ) | 
    { IFS=" "; unset PREV; while read -r NAME EQ VALUE; do
        case "$NAME" in
          "Type") T=${VALUE}; continue ;;
          "Path") F=${VALUE//"\\"/"/"}; continue ;;
          "Folder") [ "$VALUE" = + ] && FP="/"; continue       ;;
          "Attributes") A=${VALUE}; continue ;;
          "Size") SZ=${VALUE}; continue ;;
          "Packed Size") PSZ=${VALUE}; continue ;;
          "----------") T=; continue ;; 
          "Block"|"Blocks"|"CRC"|"Encrypted"|"Method"|"Modified"|"Solid") continue ;;
  "--" | \
  "7-Zip" | "Headers" | "Listing" | "Packed" | "Physical") continue ;;
          *) #echo "NAME='$NAME'" 1>&2
            ;;
        esac
        [ -n "$T" ] && continue
        case "$A" in
          D*) FP="/" ;;
        esac
        FN="$F$FP"
        DN="${F%/*}"
        output_line 
      done
      output_line 
    }
    )
    shift
  done)
}
