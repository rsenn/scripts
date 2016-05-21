list-slackpkgs()
{
    ( [ -z "$*" ] && set -- .;
    for ARG in "$@";
    do
        find "$ARG" -type f -name "*.t?z";
    done | ${SED-sed} 's,^\./,,' )
}
