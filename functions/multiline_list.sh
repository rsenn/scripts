multiline_list()
{ 
    local indent='  ' IFS="
";
    while [ "$1" != "${1#-}" ]; do
        case $1 in 
            -i)
                indent=$2 && shift 2
            ;;
            -i*)
                indent=${2#-i} && shift
            ;;
        esac;
    done;
    if test -z "$*" || test "$*" = -; then
        cat;
    else
        echo "$*";
    fi | while read item; do
        echo " \\";
        echo -n "$indent$item";
    done
}
