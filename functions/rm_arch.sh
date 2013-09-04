rm_arch()
{ 
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed -u 's,\.[^\.]*$,,' )
}
