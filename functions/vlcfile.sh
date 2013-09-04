vlcfile()
{ 
    ( IFS="
";
    set -- ` handle -p $(vlcpid)|grep -vi "$(cygpath -m "$WINDIR"| sed 's,/,.,g')"  |sed -n -u 's,.*: File  (RW-)\s\+,,p'
`;
    for X in "$@";
    do
        X=`cygpath "$X"`;
        test -f "$X" && echo "$X";
    done )
}
