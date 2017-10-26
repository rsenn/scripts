config-enable() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|${ENTRY## }=y|"
	  echo "\\|# ${ENTRY## } is not set| s|.*|${ENTRY## }=y|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}
