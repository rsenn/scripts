proc-mount()
{
  NL="
"
    for ARG in "$@";
    do
        ( ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "^$ARG" /proc/mounts );
    done
}
