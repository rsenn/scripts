choco-joinlines() {
 (LINENO=0
  while LINENO=$(($LINENO + 1)); IFS=""; 	read -r LINE; do
    LINE=${LINE%$'\r'}
    IFS=$' \t'
    set -- $LINE
    case "$LINE" in
      "#"*) LINE=" $LINE" ;;
      "["*) LINE=" $LINE" ;;
    esac
    case "$LINE" in
      " "*) set -- "" "$@" ;;
    esac    
    if [ $# -eq 0 -a -n "$PKG" ]; then
    #echo "LINENO=$((LINENO)) PKG=$PKG VERSION=$VERSION LINE=$LINE" 1>&2
    echo "$PKG $VERSION - $DESC"
      PKG= VERSION= DESC=      
    elif [ -z "$PKG" -a -z "$VERSION" -a $# -eq 2 -a -n "$1" -a -n "$2" ]; then
      PKG=$1
      VERSION=$2
      DESC=""
    else
      test -z "$1" && shift 
      case "$LINE" in
        *"Description:"*)
          DESC=${LINE#*"Description: "}
          ;;
        *Tags:* | *Downloads:*)  ;;
        " "*)
          if [ -n "$DESC" ]; then
            DESC="$DESC $*"
          fi
        ;;
      esac
    fi
  done)
}