index-dir () 
{ 
    [ -z "$*" ] && set -- .;
    ( [ "$(uname -m)" = "x86_64" ] && : ${R64="64"};
    for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD"; then
            echo "Cannot write to $PWD ..." 1>&2;
            exit;
        fi;
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP=`mktemp "/tmp/XXXXXX.list"`;
        trap 'rm -f "$TEMP"; unset TEMP' EXIT;
        ( if type list-r${R64} 2> /dev/null > /dev/null; then
            list-r${R64} 2> /dev/null;
        else
            list-recursive;
        fi ) > "$TEMP";
        ( install -m 644 "$TEMP" "$PWD/files.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/files.list";
        wc -l "$PWD/files.list" 1>&2 );
    done )
}
