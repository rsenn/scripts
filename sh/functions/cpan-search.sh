cpan-search()
{
  NL="
"
    ( for ARG in "$@";
    do
        ARG=${ARG//::/-};
        URL=$(dlynx.sh "http://search.cpan.org/search?query=$ARG&mode=dist" |${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "/$ARG-[0-9][^/]*/\$" | sort -V | tail -n1 );
        test -n "$URL" && {
            dlynx.sh "$URL" | grep-archives.sh | sort -V | tail -n1
        };
    done )
}
