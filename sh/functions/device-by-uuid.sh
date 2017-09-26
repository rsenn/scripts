device-by-uuid() {
  (P='$(blkid -U "$ARG" || realpath /dev/*/by-uuid/"$ARG")'
  [ $# -gt 1 ] && P='"$ARG:" '$P ; P='echo '$P
  for ARG; do eval "$P"; done)
}
