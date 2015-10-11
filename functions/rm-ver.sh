rm-ver()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed 's,-[^-]*$,,' )
}
