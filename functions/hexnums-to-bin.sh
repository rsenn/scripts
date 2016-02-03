hexnums-to-bin()
{
    ( require str;
    unset NL;
    case $1 in
        -l)
            shift;
            NL="
"
        ;;
    esac;
    IFS=" ";
    OUT=` echo "puts -nonewline \"[format $(str_repeat $#  %c) $* ]\""|tclsh `;
    echo -n "$OUT$NL" )
}
