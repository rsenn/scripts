filter-out()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    continue 2
                ;;
            esac;
        done;
        echo "$LINE";
    done )
}
