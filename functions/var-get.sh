var-get() {
 (while [ $# -gt 0 ]; do
    eval "echo \"\$$1\""
    shift
  done)
}
