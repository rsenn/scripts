proc-mount()
{
    for ARG in "$@";
    do
        ( ${GREP-grep} --color=auto --color=auto --color=auto "^$ARG" /proc/mounts );
    done
}
