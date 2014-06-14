_cygpath()
{
    ( FMT="cygwin";
    IFS="
";
    while :; do
        case "$1" in
            -w)
                FMT="windows";
                shift
            ;;
            -m)
                FMT="mixed";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    unset CMD PRNT EXPR;
    case "$FMT" in
        mixed | windows)
            vappend EXPR 's,^/cygdrive/\(.\)\(.*\),\1:\2,'
        ;;
        cygwin)
            vappend EXPR 's,^\(.\):\(.*\),/cygdrive/\1\2,'
        ;;
    esac;
    case "$FMT" in
        mixed | cygwin)
            vappend EXPR 's,\\,/,g'
        ;;
        windows)
            vappend EXPR 's,/,\\,g'
        ;;
    esac;
    FLTR="sed -e \"\${EXPR}\"";
    if [ $# -le 0 ]; then
        PRNT="";
    else
        PRNT="echo \"\$*\"";
    fi;
    CMD="$PRNT";
    [ "$FLTR" ] && CMD="${CMD:+$CMD|}$FLTR";
    echo "! $CMD" 1>&2;
    eval "$CMD" )
}
