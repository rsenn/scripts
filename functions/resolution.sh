resolution()
{ 
    ( WIDTH=${1%%${MULT_CHAR-x}*};
    HEIGHT=${1#*${MULT_CHAR-x}};
    echo $((WIDTH / $2))${MULT_CHAR-x}$((HEIGHT / $2)) )
}
resolution()
{ 
    ( WIDTH=${1%%x*};
    HEIGHT=${1#*x};
    echo $((WIDTH * $2))x$((HEIGHT * $2)) )
}
resolution()
{ 
    ( IFS=" $IFS";
    while :; do
        case "$1" in 
            -s)
                SEPARATOR="$2";
                shift 2
            ;;
            -a)
                ASPECT=true;
                shift
            ;;
            -p)
                MULTIPLY=true;
                shift
            ;;
            -m)
                MULT_CHAR="$2";
                shift 2
            ;;
            --all-pixels)
                ALL_PIXELS=true
            ;;
            -m=*)
                MULT_CHAR="${1#-?=}";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    N="$#";
    for ARG in "$@";
    do
        ( D=$(mminfo "$ARG" |grep -iE '(width|height)=');
        set -- $D;
        eval "$D";
        if [ -n "$Width" -a -n "$Height" ]; then
            if [ "$ASPECT" = true ]; then
                RES=`echo "${Width} / ${Height}" | bc -l`;
            else
                if [ "$MULTIPLY" = true ]; then
                    RES=`expr ${Width} \* ${Height}`;
                else
                    RES="${Width}${MULT_CHAR-x}${Height}";
                fi;
            fi;
        else
            RES="";
        fi;
        [ "$ALL_PIXELS" = true ] && RES="$RES${SEPARATOR- }$((Width * Height))";
        [ "$N" -gt 1 ] && RES="$ARG${SEPARATOR- }$RES";
        echo "$RES" );
    done )
}
