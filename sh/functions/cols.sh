if [ "`type -t cols`" != alias ]; then
  cols() {
    column -c $COLUMNS
  }
fi
