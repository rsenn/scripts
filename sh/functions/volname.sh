volname() { 
 ( case "$(uname -o)" in
    *Linux*) CMD='VARS=$(blkid "$ARG"); VARS="${VARS#*:}"; (eval "$VARS"; echo "$LABEL")' ;;
   
    *) CMD=' drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n "/Volume in drive/ s,.* is ,,p")
      eval "$ECHO"' ;;
      esac
 [ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  CMD='for ARG in "$@"; do '$CMD'; done'
  eval "$CMD"
)    
}
