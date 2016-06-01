proc-mount()
{
    for ARG in "$@";
    do
        ( ${GREP-grep
-a
--line-buffered
--color=auto} "^$ARG" /proc/mounts );
    done
}
