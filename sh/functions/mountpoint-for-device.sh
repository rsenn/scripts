mountpoint-for-device()
{
    ( set -- $(${GREP-grep
-a
--line-buffered
--color=auto} "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}
