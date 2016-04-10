choco-joinlines() {
 (LINENO=0
  o() {
    PKG=$1
    VERSION=$2
    shift 2
    DESC="$*"
    
#    echo "$PKG $VERSION - $DESC"
    s=$(printf "%-30s %-21s %s\n" "$PKG" "$VERSION" "${DESC%%. *}") #$(d=32 short "$DESC") 1>&2
    
    short "$s"
  }
   short() {   : ${COLS=$(tput cols)};   s=$*; if [ "${#s}" -gt "$COLS" ]; then s=${s:0:$((COLS - 3))}...; fi; echo "$s"; }
  
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

      o "$PKG" "$VERSION" "$DESC"
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
