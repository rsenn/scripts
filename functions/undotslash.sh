undotslash()
{
    ${SED-sed} -e "s:^\.\/::" "$@"
}
