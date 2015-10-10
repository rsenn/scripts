rm-arch()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed 's,\.[^\.]*$,,' )
}
