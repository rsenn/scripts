in_path()
{ 
    local dir IFS=:;
    for dir in $PATH;
    do
        ( cd "$dir" 2> /dev/null && set -- $1 && test -e "$1" ) && return 0;
    done;
    return 127
}
