cpan-search()
{ 
    ( for ARG in "$@";
    do
        ARG=${ARG//::/-};
        URL=$(dlynx.sh "http://search.cpan.org/search?query=$ARG&mode=dist" |grep "/$ARG-[0-9][^/]*/\$" | sort -V | tail -n1 );
        test -n "$URL" && { 
            dlynx.sh "$URL" | grep-archives.sh | sort -V | tail -n1
        };
    done )
}
