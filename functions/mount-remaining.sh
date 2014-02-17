mount-remaining()
{ 
    ( MNT="${1:-/mnt}";
    for DEV in $(not-mounted-disks);
    do
        LABEL=` disk-label "$DEV"`;
        MNTDIR="$MNT/${LABEL:-${DEV##*/}}";
        mkdir -p "$MNTDIR";
        echo "Mounting $DEV to $MNTDIR ..." 1>&2;
        mount "$DEV" "$MNTDIR";
    done )
}
