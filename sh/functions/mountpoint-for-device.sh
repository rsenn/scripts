mountpoint-for-device()
{
  NL="
"
    ( set -- $(${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}
