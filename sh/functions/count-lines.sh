count-lines()
{
    ( [ $# -le 0 ] && set -- -;
    N=$#;
    for ARG in "$@";
    do
        ( set -- $( (xzcat "$ARG" 2>/dev/null ||zcat "$ARG" 2>/dev/null || bzcat "$ARG" 2>/dev/null || cat "$ARG") | wc -l);
        [ "$N" -le 1 ] && echo "$1" || printf "%10d %s\n" "$1" "$ARG" );
    done )
}
