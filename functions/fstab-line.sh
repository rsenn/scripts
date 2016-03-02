fstab-line()
{
    ( while :; do
        case "$1" in
            -u | --uuid) USE_UUID=true; shift ;;
            -l | --label) USE_LABEL=true; shift ;;
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
        LABEL=$(disk-label -E "$DEV");
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
        [ -z "$OPTS" ] && OPTS="$DEFOPTS"
        [ -n "$ADDOPTS" ] && OPTS="${OPTS:+$OPTS,}$ADDOPTS"


        [ "${FSTYPE}" = fuseblk ] && unset FSTYPE

        OPTS=${OPTS//,relatime/,noatime}
        OPTS=${OPTS//,blksize=[0-9]*/}
        OPTS=${OPTS//,errors=remount-ro/}
        OPTS=${OPTS//,user_id=0/,user_id=${USER_ID:-0}}
        OPTS=${OPTS//,uid=0/,uid=${USER_ID:-0}}
        OPTS=${OPTS//,group_id=0/,group_id=${GROUP_ID:-0}}
        OPTS=${OPTS//,gid=0/,gid=${GROUP_ID:-0}}
        printf "%-40s %-24s %-6s %-6s %6d %6d\n" "$DEV" "$MNTDIR" "${FSTYPE:-auto}" "${OPTS:-auto}" "${DUMP:-0}" "${PASS:-0}" );
    done )
}
