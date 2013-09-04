rm_ver()
{ 
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed -u 's,-[^-]*$,,' )
}
