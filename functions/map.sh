map()
{
    from=$1 to=$2;
    shift;
    while shift && [ "$#" -gt 0 ]; do
        if var_isset "$from$1"; then
            var_set "$to$1" "`var_get "$from$1"`";
        fi;
    done;
    unset -v from to
}
