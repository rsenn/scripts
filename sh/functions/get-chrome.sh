get-chrome() {
  cygpath -a "$(ps -aW | sed 's,\\,/,g' | grep -i 'chrome[^/]*exe$' | sed \
  's|.* \(.\):\(.*\)|\1:\2|' | \
  head \
  -n1)"
}
