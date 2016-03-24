mountpoint-for-device()
{
    ( set -- $(${GREP-grep} "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}
