make-slackpkg()
{
    (IFS="
"
    require str

     : ${OUTDIR="$PWD"};
    [ -z "$1" ] && set -- .;
    ARGS="$*"
IFS=";, $IFS"
   set -- $EXCLUDE '*~' '*.bak' '*.rej' '*du.txt' '*.list' '*.log' 'files.*' '*.000' '*.tmp'
   IFS="
"
  EXCLUDELIST="{$(set -- $(for_each 'str_quote "$1"' "$@"); IFS=','; echo "$*")}"
    for ARG in $ARGS;
    do
        test -d "$ARG";
        cmd="(cd \"$ARG\" >/dev/null; tar --exclude=${EXCLUDELIST} -cv --no-recursion \$(echo .; find install/ 2>/dev/null; find * -not -wholename 'install*'  |sort ) |xz -0 -f  -c  > \"$OUTDIR/\${PWD##*/}.txz\")";
        echo + "$cmd" 1>&2;
        eval "$cmd";
    done
    )
}
