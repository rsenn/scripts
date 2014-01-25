ls-l()
{ 
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD="while read  -r $* P; do  echo \"\${P}\"; done";
    echo "+ $CMD" 1>&2;
    eval "$CMD" )
}
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
    [ $# -ge 1 ] && exec <<< "$*"
    xargs -d "$IFS" ls -l -d --time-style="+%s" $ARGS -- )
}
