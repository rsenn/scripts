for-each-char()
{
    x="$1";
    shift;
    s="$*";
    n=${#s};
    i=0;
    while [ "$i" -lt "$n" ]; do
        c=${s:0:1};
        eval "$x";
        s=${s#?};
        i=$((i+1));
    done
}
