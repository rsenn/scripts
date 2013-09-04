index-dir()
{ 
    [ -z "$*" ] && set -- .;
    ( for ARG in "$@";
    do
        ( cd "$ARG";
        echo "Indexing directory $PWD ..." 1>&2;
        list-recursive > .files.list.tmp;
        mv -f .files.list.tmp files.list;
        wc -l "$PWD/files.list" 1>&2 );
    done )
}
