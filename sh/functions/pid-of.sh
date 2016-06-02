pid-of() {
 (: ${GREP=grep
-a
--line-buffered
--color=auto}
if ps --help 2>&1 | $GREP -q '\-W'; then
     PGREP_CMD='ps -aW | $GREP -i "$ARG" | awkp'
  elif type pgrep 2>/dev/null >/dev/null; then
     PGREP_CMD='pgrep -f "$ARG"'
  else
     PGREP_CMD='ps -ax | $GREP -i "$ARG" | awkp'
  fi
  for ARG in "$@"; do
    eval "$PGREP_CMD"
  done | ${SED-sed} -n 's/^\([0-9]\+\)\r\?$/\1/p')
}