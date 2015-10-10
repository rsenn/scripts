volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(${PATHTOOL:-echo} "$drive") ;;
      esac  
      drive=$(${PATHTOOL:-echo} "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
      eval "$ECHO"
  done)
}
