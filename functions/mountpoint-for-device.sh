mountpoint-for-device()
{
    ( set -- $(grep "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}
