get-firefox() {
  cygpath -a "$(ps -aW | sed 's,\\,/,g' | grep -i '/firefox[^/]*exe$' | sed \
  's|.* \(.\):\(.*\)|\1:\2|' | \
  head \
  -n1)"
}
