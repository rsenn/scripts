undotslash()
{
    sed -e "s:^\.\/::" "$@"
}
