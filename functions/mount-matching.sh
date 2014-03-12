mount-matching()
{ 
    ( MNTDIR="/mnt";
   [ "$UID" != 0 ] && SUDO=sudo 
   blkid | grep-e "$@" | { 
        IFS=" ";
        while read -r DEV PROPERTIES; do
            DEV=${DEV%:};
            unset LABEL UUID TYPE;
            eval "$PROPERTIES";
            MNT="$MNTDIR/${LABEL:-${DEV##*/}}";
            if ! is-mounted "$DEV" && ! is-mounted "$MNT"; then
                $SUDO mkdir -p "$MNT";
                echo "Mounting $DEV to $MNT ..." 1>&2;
                $SUDO mount "$DEV" "$MNT" ${MNTOPTS:+-o
"$MNTOPTS"}
            fi;
        done
    } )
}
