mminfo()
{
    ( for ARG in "$@";
    do
        minfo "$ARG" | sed -n "s,\([^:]*\):\s*\(.*\),${2:+$ARG:}\1=\2,p";
    done )
}
