list-subdirs()
{
    ( find ${@-.} -mindepth 1 -maxdepth 1 -type d | ${SED-sed} "s|^\./||" )
}
