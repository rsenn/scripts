count()
{ 
    local IFS="$newline";
    set -- `fs_list "$@"`;
    echo $#
}
