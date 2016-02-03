ls-dirs()
{
    ( [ -z "$@" ] && set -- .;
    for ARG in "$@";
    do
        ls --color=auto -d "$ARG"/*/;
    done ) | ${SED-sed} 's,^\./,,; s,/$,,'
}
