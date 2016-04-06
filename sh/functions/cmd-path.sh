cmd-path() 
{ 
   (F=`mktemp`
    trap 'rm -vf --  "$F"' EXIT
    type "$1" 2>&1 >"$F" ; R=$?

    case "$R" in
        1) return 1 ;;
        0)  ;;
        *) exit $R ;;
    esac
    O=$(<"$F"); rm -f "$F"; trap '' EXIT

    P=${O#*" is "}
    if [ -n "$P" -a -e "$P" ]; then
        echo "$P"
    else
        return 127
    fi)
}
