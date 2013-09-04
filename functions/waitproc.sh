waitproc()
{ 
    function getprocs () 
    { 
        for ARG in "$@";
        do
            pgrep -f "$ARG";
        done
    };
    while [ -n "$(getprocs "$@")" ]; do
        sleep 0.5;
    done
}
