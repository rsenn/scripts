require()
{ 
    local mask script retcode cmd="source" pre="";
    while :; do
        case $1 in 
            -p)
                cmd="echo"
            ;;
            -n)
                pre="$shlibdir/"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    script=${1%.sh};
    for mask in $shlibdir/$script.sh $shlibdir/*/${script%.sh}.sh $shlibdir/*/*/${script%.sh}.sh;
    do
        if test -r "$mask"; then
            if test "$cmd" = echo && test -n "$pre"; then
                mask=${mask#$pre};
            fi;
            $cmd "$mask";
            return 0;
        fi;
    done;
    echo "ERROR: loading shell script library $shlibdir/$script.sh" 1>&2;
    return 127
}
