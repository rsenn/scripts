sndfile-duration () 
{ 
    for ARG in "$@";
    do
        I=$(sndfile-info "$ARG"| sed 's,^Duration[: ]*,,p' -n);
        echo "$ARG${SEP-|}$I";
    done
}
