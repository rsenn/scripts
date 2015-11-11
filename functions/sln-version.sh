sln-version () 
{ 
    ( [ $# -gt 1 ] && O='""$ARG": $FVER" $VSVER' || O='"$FVER" $VSVER';
    for ARG in "$@";
    do
        ( exec < "$ARG";
        read -r LINE;
        FVER=${LINE#*"Version "};
        read -r LINE;
        case "$LINE" in 
            *Visual*Studio*)
                VSVER=${LINE#*Visual*"Studio "}
            ;;
        esac;
        eval "echo $O" );
    done )
}
