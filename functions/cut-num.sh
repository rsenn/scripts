cut-num()
{ 
    sed -u 's,^\s*[0-9]\+\s*,,' "$@"
}
