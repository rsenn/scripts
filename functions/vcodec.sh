vcodec()
{
    ( IFS="
";
      CMD='echo "${ARG:+$ARG:}$D"'
    while :; do
       case "$1" in
       *) break ;;
     esac
   done
    N="$#";
    for ARG in "$@"
    do
     ( D=$(mminfo "$ARG" |${SED-sed} -n 's,Codec ID=,,p ;  s,Writing library=,,p' )
       set -- $D
       [ $# -gt 1 ] && shift
#        while [ $# -gt 1 ]; do shift; done
        D="$1${2:+ $2}"
        [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD") || exit $?
    done )
}
