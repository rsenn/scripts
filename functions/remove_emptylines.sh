remove_emptylines()
{ 
    sed -e '/^\s*$/d' "$@"
}
