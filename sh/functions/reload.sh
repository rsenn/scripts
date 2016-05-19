reload()
{
    local script retcode var force="no";
    while :; do
        case $1 in
            -f)
                force="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    script=$(require -p -n ${1%.sh});
    name=${script%.sh}_sh;
    var=$(echo lib/$name | ${SED-sed} -e s,/,_,g);
    if test "$force" = yes; then
        verbose "Forcing reload of $script";
        local fn;
        for fn in $(${SED-sed} -n -e 's/^\([_a-z][_0-9a-z]*\)().*/\1/p' $shlibdir/$script);
        do
            case $fn in
                require | verbose | msg)
                    continue
                ;;
            esac;
            verbose "unset -f $fn";
            unset -f $fn;
        done;
    fi;
    verbose "unset $var";
    unset "$var";
    verbose "require $script";
    source "$shlibdir/$script"
}
