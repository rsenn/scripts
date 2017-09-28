volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
			NAME=$("${COMSPEC//"\\"/"/"}" /c "vol ${drive%%/*}" | sed -n ' s,\x84,, ;  s,\r$,, ; s,.*\sist\?\s,,p')
      eval "$ECHO"
  done)
}
