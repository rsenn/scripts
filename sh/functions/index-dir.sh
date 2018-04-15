index-dir () 
{ 
    [ -z "$*" ] && set -- .;
    unset OPTS
    NAME=files
    while :; do
        case "$1" in 
            -l) pushv OPTS "-l"; NAME="$NAME-l"; shift ;;
            -n|--name) NAME="$2"; shift 2 ;;
            -x | --debug)
                DEBUG=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    ( exec 9>&2;
    [ "$(uname -m)" = "x86_64" ] && : ${R64="64"};
    for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD"; then
            echo "Cannot write to $PWD ..." 1>&2;
            exit;
        fi;
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP="$PWD/${RANDOM:-$$}.list";
        trap 'rm -f "$TEMP"; unset TEMP' EXIT;
        ( if type ${LIST_R:-list-r${R64}} 2> /dev/null > /dev/null; then
            CMD=${LIST_R:-list-r${R64}};
        else
            if type list-r 2> /dev/null > /dev/null; then
                CMD=${LIST_R:-list-r}
            else
                CMD=list-recursive;
            fi;
        fi;
        [ "$DEBUG" = true ] && echo "$ARG:+ $CMD" 1>&9;
        eval "$CMD $OPTS" ) 2> /dev/null > "$TEMP";
        ( install -m 644 "$TEMP" "$PWD/$NAME.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/$NAME.list";
        wc -l "$PWD/$NAME.list" 1>&2 );
    done )
}
