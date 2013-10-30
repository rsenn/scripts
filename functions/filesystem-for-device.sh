filesystem-for-device()
{ 
    ( DEV="$1";
    set -- $(grep "^$DEV " /proc/mounts |awkp 3 );
    case "$1" in 
        fuse*)
            TYPE=$(file -<"$DEV");
            case "$TYPE" in 
                *"NTFS "*)
                    set -- ntfs
                ;;
                *"FAT (32"*)
                    set -- vfat
                ;;
                *"FAT "*)
                    set -- fat
                ;;
            esac
        ;;
    esac;
    echo "$1" )
}
