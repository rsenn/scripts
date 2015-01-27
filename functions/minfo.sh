minfo()
{
    #timeout ${TIMEOUT:-10} \
   (CMD='mediainfo "$ARG" 2>&1'
    [ $# -gt 1 ] && CMD="$CMD | addprefix \"\$ARG:\""
    CMD="for ARG; do $CMD; done"
    eval "$CMD")  | sed '#s|\s\+:\s\+|: | ; s|\s\+:\([^:]*\)$|:\1| ; s| pixels$|| ; s|: *\([0-9]\+\) \([0-9]\+\)|: \1\2|g '
}
