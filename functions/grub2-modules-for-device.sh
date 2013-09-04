grub2-modules-for-device()
{ 
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    FS=$(filesystem-for-device "$ARG");
    SUFFIX=${1##*/};
    SUFFIX=${SUFFIX#[hs]d[a-z]};
    DISK=${1%"$SUFFIX"};
    [ "$DISK" ] && PART_TYPE=$(partition-table-type "$DISK");
    case "$PART_TYPE" in 
        msdos | mbr*)
            echo "${2}insmod part_msdos"
        ;;
        gpt* | guid*)
            echo "${2}insmod gpt"
        ;;
    esac;
    case "$FS" in 
        ntfs)
            echo "${2}insmod ntfs"
        ;;
        vfat | fat32)
            echo "${2}insmod vfat"
        ;;
        fat | fat16)
            echo "${2}insmod fat"
        ;;
        hfsplus | hfs+)
            echo "${2}insmod hfsplus"
        ;;
        ext[0-9])
            echo "${2}insmod ext2"
        ;;
    esac )
}
