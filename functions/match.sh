match()
{ 
 (EXPR="$1"; shift
  CMD='case $LINE in
  $EXPR) echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")  
}
