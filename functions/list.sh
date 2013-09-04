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
#{ 
#    local indent='  ' IFS="
#";
#    while [ "$1" != "${1#-}" ]; do
#        case $1 in 
#            -i)
#                indent=$2 && shift 2
#            ;;
#            -i*)
#                indent=${2#-i} && shift
#            ;;
#        esac;
#    done;
#    if test -z "$*" || test "$*" = -; then
#        cat;
#    else
#        echo "$*";
#    fi | while read item; do
#        echo " \\";
#        echo -n "$indent$item";
#    done
#}
#list()
#{ 
#    local indent='  ' IFS="
#";
#    while [ "$1" != "${1#-}" ]; do
#        case $1 in 
#            -i)
#                indent=$2 && shift 2
#            ;;
#            -i*)
#                indent=${2#-i} && shift
#            ;;
#        esac;
#    done;
#    if test -z "$*" || test "$*" = -; then
#        cat;
#    else
#        echo "$*";
#    fi | while read item; do
#        echo " \\";
#        echo -n "$indent$item";
#    done
#}
#

locate-filename()
{ 
    ( IFS="
 ";
    unset TEST_ARGS;
    while :; do
        case "$1" in 
            -i)
                IGNORE_CASE=true;
                shift
            ;;
            -r)
                REGEXP=true;
                shift
            ;;
            -a | -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -s | -u | -w | -x)
                TEST_ARGS="${TEST_ARGS:+$TEST_ARGS
}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    LOCATE_ARGS=;
    if [ "$IGNORE_CASE" = true ]; then
        LOCATE_ARGS="${LOCATE_ARGS:+$LOCATE_ARGS
}-i" GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
}-i";
    fi;
    for EXPR in "$@";
    do
        if [ "$REGEXP" != true ]; then
            EXPR=${EXPR//"."/"\\."};
            EXPR=${EXPR//"?"/"."};
            EXPR=${EXPR//"*"/"[^/]*"};
            case "$EXPR" in 
                *"[^/]*")

                ;;
                *)
                    EXPR="$EXPR\$"
                ;;
            esac;
            case "$EXPR" in 
                "[^/]*"*)

                ;;
                *)
                    EXPR="^$EXPR"
                ;;
            esac;
            REGEXP=true;
        fi;
        if [ "$REGEXP" = true ]; then
            case "$EXPR" in 
                *\$)

                ;;
                *)
                    EXPR="${EXPR%"[^/]*"}[^/]*\$"
                ;;
            esac;
            case "$EXPR" in 
                ^*)
                    EXPR="/${EXPR#^}"
                ;;
            esac;
            EXPR=${EXPR//'.*'/'[^/]*'};
        fi;
        CMD='(set -x; locate $LOCATE_ARGS -r "$EXPR") ';
        if [ -n "$TEST_ARGS" ]; then
            CMD="$CMD | filter-test \$TEST_ARGS";
        fi;
        CMD="$CMD | (set -x ; grep \$GREP_ARGS \"\${EXPR#/}\") ";
        eval "$CMD";
    done )
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
