mountpoint-for-file()
{
    ( df "$1" | sed 1d | awkp 6 )
}
