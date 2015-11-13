volname() {
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  if [ -d /dev/disk/by-label ]; then
    for ARG; do
      for link in /dev/disk/by-label/*; do
        NAME=${link##*/}
        dev=$(realpath "$link")
        if [ "$dev" = "$ARG" ]; then
          eval "$ECHO"
        fi
       done
    done
  else
    for ARG in "$@"; do
        drive="$ARG"
        case "$drive" in
          ?) drive="$drive:" ;;
          ?:*) drive=${drive%%:*}: ;;
          *) drive=$(${PATHTOOL:-echo} ${PATHTOOL:+-m} "$drive") ; drive=${drive%%:*}: ;;
        esac  
        #drive=$(${PATHTOOL:-echo} "$drive")
        NAME=$(cmd /c "vol ${drive%%[\\/]*}" | sed -n '/Volume in drive/ s,.* is ,,p')
        eval "$ECHO"
    done
  fi)
}
