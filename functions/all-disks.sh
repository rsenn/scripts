all-disks()
{
   (case "$1" in
      -l) SHOW_LABEL=true; shift ;;
      -u) SHOW_UUID=true; shift ;;
    esac
    if [ -z "$1" ]; then
        set -- /dev/disk/by-{uuid,label};
    fi;
    find "$@" -type l | while read -r FILE; do
       if [ "$SHOW_LABEL" = true ]; then
   case "$FILE" in
       /dev/disk/by-label/*) echo "LABEL=${FILE##*/}" ;;
   esac
       elif [ "$SHOW_UUID" = true ]; then
   case "$FILE" in
       /dev/disk/by-uuid/*) echo "UUID=${FILE##*/}" ;;
   esac
       else
        myrealpath "$FILE";
       fi
    done | sort -u
    )
}
