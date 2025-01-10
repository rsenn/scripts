if [ "`type -t cols`" = "" ]; then
  unalias cols
  unset -f cols
  cols() {
    column -c $COLUMNS
  }
fi
