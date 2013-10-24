ls-l()
{ 
    ( IFS="
";
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
    exec <<< "$*";
    xargs -d "$IFS" ls -l -d --time-style="+%s" $ARGS -- )
}
