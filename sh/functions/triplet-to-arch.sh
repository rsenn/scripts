triplet-to-arch () 
{ 
    ( for TRIPLET in "$@";
    do
        ( BITS=;
        case "$TRIPLET" in 
            *x86?64* | *x64* | *amd64*)
                BITS=64
            ;;
            *i[3-8]86* | *x32* | *x86*)
                BITS=32
            ;;
        esac;
        OS=${TRIPLET%-gnu};
        OS=${OS##*/};
        OS=${OS%32};
        echo "$OS$BITS" );
    done )
}
