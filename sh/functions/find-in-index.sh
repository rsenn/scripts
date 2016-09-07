 find-in-index() {
  (CMD='index-dir -u $DIRS | xargs ${GREP-grep
-a
--line-buffered
--color=auto} -E "($EXPRS)" -H | ${SED-sed} "s|/files.list:|/|" -u'
   while :; do
     case "$1" in
       -w | -m) CMD="$CMD | msyspath $1"; shift ;;
       *) break ;;
     esac
    done


  while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushv DIRS "$1"
    else
      EXPRS="${EXPRS:+$EXPRS|}$1"
    fi
    shift
  done
  eval "$CMD"
)
}

