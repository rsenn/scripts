findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}
findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}
findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}
