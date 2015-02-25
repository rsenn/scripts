for_each()
{
#    old_IFS=$IFS; IFS="$IFS "
    __=$1;
    test "`type -t "$__"`" = function && __="$__ \"\$@\"";
    while shift;
    [ "$#" -gt 0 ]; do
        eval "$__";
    done;
    unset __
#    IFS=$old_IFS
}
