mount-matching()
{ 
    ( MNTDIR="/mnt";
    blkid | grep-e "$@" | { 
        IFS=" ";
        while read -r DEV PROPERTIES; do
            DEV=${DEV%:};
            unset LABEL UUID TYPE;
            eval "$PROPERTIES";
            MNT="$MNTDIR/${LABEL:-${DEV##*/}}";
            if ! is-mounted "$DEV" && ! is-mounted "$MNT"; then
                mkdir -p "$MNT";
                echo "Mounting $DEV to $MNT ..." 1>&2;
                mount "$DEV" "$MNT" ${MNTOPTS:+-o
"$MNTOPTS"}
            fi;
        done
    } )
}
