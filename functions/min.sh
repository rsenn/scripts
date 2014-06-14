min()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -lt "$i" ] && i="$1";
    done;
    echo "$i" )
}
