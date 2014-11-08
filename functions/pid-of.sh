pid-of() {
   (if ps --help 2>&1 |grep -q '\-W'; then
       PGREP_CMD='ps -aW |grep "$ARG" | awkp'
    elif type pgrep 2>/dev/null >/dev/null; then
       PGREP_CMD='pgrep -f "$ARG"'
    else
       PGREP_CMD='ps -ax | grep "$ARG" | awkp'
    fi
    for ARG in "$@"; do
      eval "$PGREP_CMD"
    done | sed -n "/^[0-9]\+$/p")
}
