remove-emptylines()
{
    sed -e '/^\s*$/d' "$@"
}
