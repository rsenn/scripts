partition-table-type()
{
    ( if command-exists "parted"; then
        parted "$1" p | sed -n 's,.*Table:\s\+,,p';
    else
        ( eval "$(  gdisk -l "$(disk-device-for-partition "$1")" |sed 's,\s*not present$,,' |sed -n  's,^\s*\([[:upper:]]\+\):\(\s*\)\(.*\),\1="\3",p')";
        if [ "$MBR" -a "$GPT" ]; then
            echo "mbr+gpt";
        else
            if [ "$MBR" ]; then
                echo "mbr";
            else
                if [ "$GPT" ]; then
                    echo "gpt";
                fi;
            fi;
        fi );
    fi )
}
