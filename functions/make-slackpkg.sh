make-slackpkg()
{ 
    : ${DESTDIR="$PWD"};
    [ -z "$1" ] && set -- .;
    for ARG in "$@";
    do
        test -d "$ARG";
        cmd="(cd \"$ARG\"; tar --exclude={'*~','*.bak','*.rej','*du.txt'} -cv --no-recursion \$(echo .; find install/ 2>/dev/null; find * -not -wholename 'install*'  |sort ) |xz -0 -f  -c  > \"$DESTDIR/\${PWD##*/}.txz\")";
        echo + "$cmd" 1>&2;
        eval "$cmd";
    done
}
