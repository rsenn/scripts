mount-remaining()
{ 
    ( MNT="${1:-/mnt}";
    [ "$UID" != 0 ] && SUDO=sudo
    for DEV in $(not-mounted-disks);
    do
        LABEL=` disk-label "$DEV"`;
        MNTDIR="$MNT/${LABEL:-${DEV##*/}}";
        $SUDO mkdir -p "$MNTDIR";
        echo "Mounting $DEV to $MNTDIR ..." 1>&2;
        $SUDO mount "$DEV" "$MNTDIR" ${MNTOPTS:+-o
"$MNTOPTS"};
    done )
}
