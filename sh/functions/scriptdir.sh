scriptdir()
{
    local absdir reldir thisdir="`pwd`";
    if [ "$0" != "${0%/*}" ]; then
        reldir="${0%/*}";
    fi;
    if [ "${reldir#/}" != "$reldir" ]; then
        absdir=`cd $reldir && pwd`;
    else
        absdir=`cd $thisdir/$reldir && pwd`;
    fi;
    echo $absdir
}
