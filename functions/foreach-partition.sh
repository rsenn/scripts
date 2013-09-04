foreach-partition()
{ 
    local old_IFS="$IFS";
    blkid | { 
        IFS="
 ";
        while read -r DEV VARS; do
            DEV=${DEV%:};
            eval "DEV=\"$DEV\" $VARS";
            eval "$*";
        done
    };
    IFS="$old_IFS"
}
