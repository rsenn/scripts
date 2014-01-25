blkvars()
{ 
    eval "$(IFS=" "; set -- `blkid "$1"`; shift; echo "$*")"
}
