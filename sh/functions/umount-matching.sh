umount-matching()
{
    ( grep-e "$@" < /proc/mounts | {
        IFS=" ";
        while read -r DEV MNT TYPE OPTS N M; do
            echo "Unmounting $DEV, mounted at $MNT ..." 1>&2;
            umount $ADDOPTS "$MNT" || umount $ADDOPTS "$MNT";
        done
    } )
}
