all-disks()
{ 
    if [ -z "$1" ]; then
        set -- /dev/disk/by-{uuid,label};
    fi;
    find "$@" -type l | while read -r FILE; do
        myrealpath "$FILE";
    done | sort -u
}
