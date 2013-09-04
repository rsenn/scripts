importlibs()
{ 
    local lib IFS="|";
    for lib in $__LIBS__;
    do
        if ! source $shlibdir/$lib.sh 2> /dev/null; then
            echo "Error loading $lib.sh" 1>&2;
            return $?;
        fi;
    done
}
