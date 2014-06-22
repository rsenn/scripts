matchall()
{
    ( STR="$1";
    shift;
    while [ $# -gt 0 ]; do
        case "$STR" in
            $1)

            ;;
            *)
                exit 1
            ;;
        esac;
        shift;
    done;
    exit 0 )
}
