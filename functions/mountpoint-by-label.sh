mountpoint-by-label() {
 (IFS="
 	"
  for MNT in $(wmic Path win32_volume where "Label='$1'" Get DriveLetter /format:list 2>&1); do
    case "$MNT" in
      DriveLetter=*) 
        MNT=${MNT#DriveLetter=}
        MNT=${MNT:0:1}:
        break
      ;;
    esac
  done
  [ -n "$MNT" ] && { echo "$MNT" | tr "[:"{upper,lower}":]"; })
} ||

mountpoint-by-label() {
 (if [ -e /dev/disks/by-label/"$1" ]; then
    mountpoint-for-device "$1"
  else
    DEV=$(blkid -L "$1")
    if [ -n "$DEV" -a -e "$DEV" ]; then
      mountpoint-for-device "$DEV"
    fi
  fi)
}
