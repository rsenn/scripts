window-id() {
 (xwininfo "$@" |sed '/Window id:/ s|.* id: \([^ ]*\) .*|\1|p' -n)
}
 
