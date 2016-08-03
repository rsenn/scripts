rm-arch()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    ${SED-sed} 's,\.[^\.]*$,,' )
}
