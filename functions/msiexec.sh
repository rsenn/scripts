msiexec()
{ 
    ( IFS="
";
    IFS=" $IFS";
    while :; do
        case "$1" in 
            -*)
                ARGS="${ARGS+
}/${1#-}";
                shift
            ;;
            /?)
                ARGS="${ARGS+
}${1}";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    "$COMSPEC" "/C" "${MSIEXEC} $ARGS $(msyspath -w "$@")" )
}
