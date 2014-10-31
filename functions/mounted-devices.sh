mounted-devices() {
  (IFS=" "
	unset PREV
	while read -r DEV MNT FSTYPE OPTS A B; do
		case "$DEV" in
			rootfs | /dev/root) DEV=`get-rootfs` ;;
			/*) ;;
			*) continue	;;
		esac
		[ "$DEV" != "$PREV" ] && echo "$DEV"
		PREV="$DEV"
	done) </proc/mounts
}
