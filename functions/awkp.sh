awkp()
{
    ( IFS="
	";
    N=${1};
    set -- awk;
    case $1 in
        -[A-Za-z]*)
            set -- "$@" "$1";
            shift
        ;;
    esac;
    "$@" "{ print \$${N:-1} }" )
}
