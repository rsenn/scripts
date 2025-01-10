if [ "`type -t cols`" != alias ]; then
  unalias cols
  cols() {
    column -c $COLUMNS
  }
fi
