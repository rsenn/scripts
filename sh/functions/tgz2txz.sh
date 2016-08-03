tgz2txz()
{
    ( for ARG in "$@";
    do
        zcat "$ARG" | ( xz -9 -v -f -c > "${ARG%.tgz}.txz" && rm -vf "$ARG" );
    done )
}
