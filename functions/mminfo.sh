mminfo()
{ 
    ( for ARG in "$@";
    do
        minfo "$ARG" | sed -u -n "s,\([^:]*\):\s*\(.*\),${2:+$ARG:}\1=\2,p";
    done )
}
