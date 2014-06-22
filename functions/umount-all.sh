umount-all()
{
    for ARG in "$@";
    do
        umount "$ARG";
    done
}
