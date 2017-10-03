proc-mount()
{
    for ARG in "$@";
    do
        ( ${GREP-grep} "^$ARG" /proc/mounts );
    done
}
