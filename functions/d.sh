d()
{ 
    ( case "$1" in 
        ?:*)
            set -- /cygdrive/${1%%:*}${1#?:}
        ;;
    esac;
    echo "$1" )
}
