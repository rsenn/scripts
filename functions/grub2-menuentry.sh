grub2-menuentry()
{
    ( NAME="$1";
    : ${INDENT="  "};
    shift;
    echo "menuentry '$NAME' {";
    IFS=" ";
    IFS="$IFS
";
    ENTRY="$*";
    unset LINE;
    function output-line()
    {
        [ "$LINE" ] && echo "$INDENT"$LINE;
        unset LINE
    };
    for WORD in $ENTRY;
    do
        case $WORD in
            acpi | chainloader | configfile | drivemap | echo | export | initrd | insmod | kernel | linux | linux16 | loadfont | menuentry | password | play | removed | search | set | source | submenu | timeout)
                output-line
            ;;
        esac;
        LINE="${LINE+$LINE
}$WORD";
    done;
    output-line;
    echo "}" )
}
