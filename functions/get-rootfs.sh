get-rootfs() {
	sed -n 's,.*root=\([^ ]\+\).*,\1,p' /proc/cmdline
}
