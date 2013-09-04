max()
{ 
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -gt "$i" ] && i="$1";
    done;
    echo "$i" )
}
