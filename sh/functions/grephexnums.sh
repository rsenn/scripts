grephexnums()
{
  NL="
"
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
    ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -E $ARGS "(${*#0x})" )
}
