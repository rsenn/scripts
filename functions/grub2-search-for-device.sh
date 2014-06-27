grub2-search-for-device()
{
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    BLKID=$(blkid "$ARG");
    eval "${BLKID#*": "}";
    echo "${2}search --no-floppy --fs-uuid --set" $UUID )
}
