lines()
{
    for ARG in "$@";
    do
        N=$( set -- $ARG; (xzcat "$1" || bzcat "$1" || zcat "$1" || cat "$1") 2>/dev/null | wc -l);
        test "$#" -gt 1 && printf "%10d %s\n" $N $ARG || echo "$N";
    done
}
