rpm-cmd() {
  OPTS= OUTPUT=
  while :; do
    case "$1" in
      -o) OUTPUT="$2"; shift 2 ;; -o*) OUTPUT="${1#-o}"; shift  ;; --output=*) OUTPUT="${1#*=}"; shift  ;;
      -*) OPTS="${OPTS:+$OPTS$IFS}$1"; shift ;;
      --) shift; break ;;
      *) break ;;
    esac
  done
  while [ $# -gt 0 ]; do
    ARG="$1"
    shift
   (case "$ARG" in
      #*://*) CMD='wget -q -O - "$ARG" | rpm2cpio /dev/stdin' ;;
      #*://*) CMD='lynx -source "$ARG" | rpm2cpio /dev/stdin' ;;
      #*://*) CMD='lynx -source "$ARG" | rpm2cpio /dev/stdin' ;;
    *://*) 
      MIRRORLIST=`curl -s "$ARG.mirrorlist" |sed -n 's,\s*<li><a href="\([^"]*\.rpm\)">.*,\1,p'`

      if [ -n "$MIRRORLIST" ]; then
        set -- $MIRRORLIST 
      else
        set -- "$ARG"
      fi
      CMD='wget -q -O - "$1" | rpm2cpio /dev/stdin'
      ;;
      *) set -- "$ARG"
        CMD='rpm2cpio "$ARG"'
        ;;
    esac
    CMD="$CMD | (${OUTPUT:+cd \"\$OUTPUT\"; }cpio \${OPTS:--t} 2>/dev/null)"
    while [ $# -gt 0 ]; do 
      eval "( $CMD ) 2>/dev/null" && exit 0
      #echo continue 1>&2
      shift
    done
    
    echo "Failed to list $ARG" 1>&2
    exit 1)
  done
}

rpm-list() {
  rpm-cmd -t -- "$@"
}

rpm-extract() {
  rpm-cmd -i -d -u -- "$@"
}
