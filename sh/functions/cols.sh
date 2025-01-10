if [ "`type -t cols`" = "" ]; then
  cols() {
    column -c $COLUMNS
  }
fi
