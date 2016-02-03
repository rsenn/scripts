get-rootfs() {
  ${SED-sed} -n 's,.*root=\([^ ]\+\).*,\1,p' /proc/cmdline
}
