filter()
{ 
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in 
                $PATTERN)
                    echo "$LINE";
                    break
                ;;
            esac;
        done;
    done )
}
