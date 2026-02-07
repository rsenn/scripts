if [ "`type -t cols`" = "" ]; then
  unalias cols >&/dev/null
  unset -f cols >&/dev/null
  cols() {
    column -c $COLUMNS
  }
fi
