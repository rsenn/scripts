proc-mount()
{ 
    for ARG in "$@";
    do
        ( grep --color=auto --color=auto --color=auto "^$ARG" /proc/mounts );
    done
}
