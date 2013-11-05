fstab-line()
{ 
    ( while :; do
        case "$1" in 
            -u | --uuid)
                USE_UUID=true;
                shift
            ;;
            -l | --label)
                USE_LABEL=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    IFS="
 ";
    : ${MNT="/mnt"};
    for DEV in "$@";
    do
        ( unset DEVNAME LABEL MNTDIR #FSTYPE;
        DEVNAME=${DEV##*/};
        LABEL=$(disk-label "$DEV");
        [ -z "$MNTDIR" ] && MNTDIR="$MNT/${LABEL:-$DEVNAME}";
        : ${FSTYPE=$(filesystem-for-device "$DEV")}
        UUID=$(getuuid "$DEV");
        set -- $(proc-mount "$DEV");
        [ -n "$4" ] && : ${OPTS:="$4"};
        [ -n "$5" ] && DUMP="$5";
        [ -n "$6" ] && PASS="$6";
        [ "$USE_UUID" = true -a -n "$UUID" ] && DEV="UUID=$UUID";
        [ "$USE_LABEL" = true -a -n "$LABEL" -a -e /dev/disk/by-label/"$LABEL" ] && DEV="LABEL=$LABEL";
        case "$FSTYPE" in 
            swap)
                MNTDIR=none;
                : ${OPTS:=sw}
            ;;
        esac;
        printf "%-40s %-14s %-6s %-6s %6d %6d\n" "$DEV" "$MNTDIR" "${FSTYPE:-auto}" "${OPTS:-auto}" "${DUMP:-0}" "${PASS:-0}" );
    done )
}
