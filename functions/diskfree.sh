diskfree()
{ 
    set -- `df -B1 -P "$@" | tail -n1`;
    echo $4
}
