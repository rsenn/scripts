vlcfile()
{
    ( IFS="
";
    set -- ` handle -p $(vlcpid)|${GREP-grep} -vi "$(${PATHTOOL:-echo} "$WINDIR"| ${SED-sed} 's,/,.,g')"  |${SED-sed} -n -u 's,.*: File  (RW-)\s\+,,p'
`;
    for X in "$@";
    do
        X=`cygpath "$X"`;
        test -f "$X" && echo "$X";
    done )
}
