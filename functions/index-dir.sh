index-dir() { 
  [ -z "$*" ] && set -- .
  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  ( 
  [ "$(uname -m)" = "x86_64" ] && : ${R64="64"}
  for ARG in "$@"; do
   (cd "$ARG"
    if ! test -w "$PWD"; then
        echo "Cannot write to $PWD ..." 1>&2
        exit
    fi
    echo "Indexing directory $PWD ..." 1>&2
    TEMP=`mktemp "$PWD/XXXXXX.list"`
    trap 'rm -f "$TEMP"; unset TEMP' EXIT
    ( if type list-r${R64} 2>/dev/null >/dev/null; then  
        CMD=list-r${R64} 
      elif type list-r 2>/dev/null >/dev/null; then  
        CMD=${R64} 
      else 
        CMD=list-recursive
      fi
[ "$DEBUG" = true ] && echo "$ARG:+ $CMD" 1>&2
      eval "$CMD"
    ) 2>/dev/null >"$TEMP"
    ( install -m 644 "$TEMP" "$PWD/files.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/files.list"
    wc -l "$PWD/files.list" 1>&2 )
  done )
}
