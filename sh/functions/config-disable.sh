config-disable() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|# ${ENTRY## } is not set|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}
