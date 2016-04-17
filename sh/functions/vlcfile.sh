vlcfile()
{
  NL="
"
    ( IFS="
";
    set -- ` handle -p $(vlcpid)|${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -vi "$(${PATHTOOL:-echo} "$WINDIR"| ${SED-sed} 's,/,.,g')"  |${SED-sed} -n -u 's,.*: File  (RW-)\s\+,,p'
`;
    for X in "$@";
    do
        X=`cygpath "$X"`;
        test -f "$X" && echo "$X";
    done )
}
