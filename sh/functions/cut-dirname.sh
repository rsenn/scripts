cut-dirname()
{
    ${SED-sed} "s,\\(.*\\)[/\\\\]\\([^/\\\\]\\+[/\\\\]\\?\\)${1//./\\.}\$,\2,"
}
