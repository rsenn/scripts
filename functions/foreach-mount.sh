foreach-mount()
{
    local old_IFS="$IFS";
    {
        IFS="
 ";
        while read -r DEV MNT TYPE OPTS A B; do
            eval "$*";
        done < /proc/mounts
    };
    IFS="$old_IFS"
}
