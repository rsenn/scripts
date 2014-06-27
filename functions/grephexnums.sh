grephexnums()
{
    ( IFS="|";
    unset ARGS;
    while :; do
        case "$1" in
            -*)
                ARGS="${ARGS+$ARGS$IFS}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    set -x;
    grep --color=auto --color=auto --color=auto -E $ARGS "(${*#0x})" )
}
