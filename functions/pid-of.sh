pid-of()
{
    ( for ARG in "$@";
    do
        (
        if type pgrep 2>/dev/null >/dev/null; then
          pgrep -f "$ARG"
        else
          ps -aW |grep "$ARG" | awkp
        fi | sed -n "/^[0-9]\+$/p"
        )
    done )
}
