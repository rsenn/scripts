rm-ver()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    ${SED-sed} 's,-[^-]*$,,' )
}
