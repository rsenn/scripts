make-slackpkg()
{ 
    (IFS="
"
    require str 
    
     : ${DESTDIR="$PWD"};
    [ -z "$1" ] && set -- .;
    ARGS="$*"
IFS=";, $IFS"
   set -- $EXCLUDE '*~' '*.bak' '*.rej' '*du.txt' '*.list' '*.log' 'files.*' '*.000' '*.tmp'
   IFS="
"
  EXCLUDELIST="{$(set -- $(for_each str_quote "$@"); IFS=','; echo "$*")}"
    for ARG in $ARGS;
    do
        test -d "$ARG";
        cmd="(cd \"$ARG\"; tar --exclude=${EXCLUDELIST} -cv --no-recursion \$(echo .; find install/ 2>/dev/null; find * -not -wholename 'install*'  |sort ) |xz -0 -f  -c  > \"$DESTDIR/\${PWD##*/}.txz\")";
        echo + "$cmd" 1>&2;
        eval "$cmd";
    done
    )
}
