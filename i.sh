index-dir () 
{ 
    [ -z "$*" ] && set -- .;
    ( for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD"; then
            echo "Cannot write to $PWD ..." 1>&2;
            exit;
        fi;
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP=`mktemp "$PWD/XXXXXX.list"`;
        trap 'rm -f "$TEMP"; unset TEMP' EXIT;
        ( if type list-r64 2> /dev/null > /dev/null; then
            list-r64 2> /dev/null;
        else
            list-recursive;
        fi ) > "$TEMP";
        ( install -m 644 "$TEMP" "$PWD/files.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/files.list";
        wc -l "$PWD/files.list" 1>&2 );
    done )
}
