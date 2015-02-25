proc-by-pid() {
  if ps --help 2>&1 |grep -q '\-W'; then
    PSARGS="-W"
  fi
  for ARG; do
     ps $PSARGS -p "$ARG" | sed 1d
  done |cut-ls-l 7
}