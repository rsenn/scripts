mountpoint-for-file()
{
    ( df "$1" | ${SED-sed} 1d | awkp 6 )
}
