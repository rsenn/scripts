is-checking() {
  ps -aW | grep --color=auto --line-buffered --text -q chkdsk
}
