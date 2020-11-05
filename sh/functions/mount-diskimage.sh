mount-diskimage() {
  IMG="$1"; exec_cmd() {
      echo "+ $@" >&2; sudo "$@"
}; sfdisk -d "${IMG}" | {
IFS=" "; \
  : ${I:=1}; while read DEV PART; do case "${PART}" in
      *start=*) START=${PART##*start=}
        START=${START%%,*}
        START=$((START)) ;;
      *) continue ;;
    esac; \
    exec_cmd losetup -o $((START*512)) /dev/loop$I "$1"; \
    MNT=/media/"${IMG##*/}-part1"; \
    exec_cmd mkdir -p "${MNT}"; \
    exec_cmd mount /dev/loop$I "${MNT}"; done; }
}
