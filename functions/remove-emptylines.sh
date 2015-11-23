remove-emptylines()
{
    ${SED-sed} -e '/^\s*$/d' "$@"
}
