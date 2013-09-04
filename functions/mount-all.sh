mount-all()
{ 
    for ARG in "$@";
    do
        mount "$ARG";
    done
}
