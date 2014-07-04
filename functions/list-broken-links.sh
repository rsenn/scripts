list-broken-links() {
  (for ARG; do
    DIR=`dirname "$ARG"`
    BASE=`basename "$ARG"`

    TARGET=$(cd "$DIR"; readlink "$BASE")
    
    ABS="$DIR/$TARGET"

    test -e "$ABS" || echo "$ARG"
   done)
}
