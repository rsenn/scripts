disk-devices() {
  wmic volume get DeviceID /VALUE | while read -r LINE; do
    case "$LINE" in
      *=*) echo "${LINE##*=}" ;;
    esac
  done
} ||

disk-devices() {
    foreach-partition 'echo "$DEV"'
}
