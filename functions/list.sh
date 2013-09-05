list()
{ 
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
{ 
    sed -u "s|/files\.list:|/|"
}
list()
{ 
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
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
