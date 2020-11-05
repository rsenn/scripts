lookup-grub-devicemap() {
  arg=$(realpath "$1"); (IFS='	 '
  while read -r grubdisk diskdev; do realdev=$(realpath "${diskdev}"); \
    test -n "${realdev}" || continue; case "${arg}" in
      $realdev*) echo "${grubdisk}"
        exit ;;
    esac; done) <\
${devicemap:-device.map}\

}
