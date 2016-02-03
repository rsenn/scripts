rpm-extract() {
  rpm-cmd -i -d -u -- "$@"
}
