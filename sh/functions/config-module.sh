config-module() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|${ENTRY## }=m|"
	  echo "\\|# ${ENTRY## } is not set| s|.*|${ENTRY## }=m|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}
