pid-of()
{
  NL="
"
   (if ps --help 2>&1 |${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q '\-W'; then
       PGREP_CMD='ps -aW |${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -i "$ARG" | awkp'
    elif type pgrep 2>/dev/null >/dev/null; then
       PGREP_CMD='pgrep -f "$ARG"'
    else
       PGREP_CMD='ps -ax | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -i "$ARG" | awkp'
    fi
    for ARG in "$@"; do
      eval "$PGREP_CMD"
    done | ${SED-sed} -n 's/^\([0-9]\+\)\r\?$/\1/p')
}
