cut-arch()
{
    ${SED-sed} 's,^\([^ ]*\)\.[^ .]*\( - \)\?\(.*\)$,\1\2\3,'
}