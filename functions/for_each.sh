for_each()
{
    __=$1;
    test "`type -t "$__"`" = function && __="$__ \"\$@\"";
    while shift;
    [ "$#" -gt 0 ]; do
        eval "$__";
    done;
    unset __
}
