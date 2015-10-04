 find-in-index() {
  (while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushv DIRS "$1"
    else
      EXPRS="${EXPRS:+$EXPRS|}$1"
    fi
    shift
  done
  index-dir -u $DIRS | xargs grep -E "($EXPRS)" -H | sed "s|/files.list:|/|" -u
)
}

