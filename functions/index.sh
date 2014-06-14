index()
{
    ( INDEX=`expr ${1:-0} + 1`;
    shift;
    echo "$*" | cut -b"$INDEX" )
}
