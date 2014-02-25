mount-all()
{ 
    for ARG in "$@";
    do
        mount "$ARG" ${MNTOPTS:+-o
"$MNTOPTS"}
    done
}
