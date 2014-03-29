cut-ls-l()
{ 
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD="while read  -r $* P; do  echo \"\${P}\"; done";
#    echo "+ $CMD" 1>&2;
    eval "$CMD" )
}
