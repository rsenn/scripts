linedelay()
{
    unset o;
    while read i; do
        test "${o+set}" = set && echo "$o";
        o=$i;
    done;
    test "${o+set}" = set && echo "$o"
}
