ls-files()
{
    ( [ -z "$@" ] && set -- .;
    for ARG in "$@";
    do
        ls --color=auto -d "$ARG"/*;
    done ) | filter-test -f| sed 's,^\./,,; s,/$,,'
}
