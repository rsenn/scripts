symlink-lib()
{
    ( while :; do
        case "$1" in
            -p)
                PRINT_ONLY=echo;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    for ARG in "$@";
    do
        ( IFS=".";
        set -- $ARG;
        unset NAME;
        while [ "$1" != so ]; do
            NAME="${NAME+$NAME${IFS:0:1}}$1";
            shift;
        done;
        I=$(( $# - 1 ));
        N=$#;
        unset PREV;
        while [ "$I" -ge 1 ]; do
            EXT=$(rangearg 1  "$I" "$@");
            LINK="$NAME${EXT:+.$EXT}";
            TARGET="$ARG";
            [ -n "$PREV" ] && TARGET="$PREV";
            ${PRINT_ONLY} ln -svf "$TARGET" "$LINK";
            I=$((I - 1));
            PREV="$LINK";
        done );
    done )
}
