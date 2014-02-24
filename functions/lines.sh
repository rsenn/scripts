<<<<<<< HEAD
lines () 
=======
lines()
>>>>>>> 920a4a7eb2d8d4ebe7a624d237d7d9aad809de43
{ 
    for ARG in "$@";
    do
        N=$( set -- $ARG; (xzcat "$1" || bzcat "$1" || zcat "$1" || cat "$1") 2>/dev/null | wc -l);
        test "$#" -gt 1 && printf "%10d %s\n" $N $ARG || echo "$N";
    done
}
