index-dir()
{ 
    [ -z "$*" ] && set -- .;
    ( for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD" ; then
          echo "Cannot write to $PWD ..." 1>&2
          exit
        fi
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP=`mktemp /tmp/"${PWD##*/}XXXXXX.list"`
        trap 'rm -f "$TEMP"; unset TEMP' EXIT
        (list-r 2>/dev/null || list-recursive) >"$TEMP";
        mv -f "$TEMP" "$PWD/files.list";
        wc -l "$PWD/files.list" 1>&2 );
    done )
}
