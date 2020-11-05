vlc-current-file() {
  handle $(pid-args vlc.exe) | cut-ls-l 3 | filter-test -s | grep-videos.sh | \
  sed \
  's,\\,/,g; 1p' \
  -n
}
