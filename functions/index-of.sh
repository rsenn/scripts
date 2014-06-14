index-of()
{
    io="$1";
    shift;
    s="$*";
    for-each-char 'if [ "$io" = "$c" ]; then echo "$i"; return 0; fi' "$s"
}
