bin2dec() {
  while [ $# -gt 0 ]; do
	eval 'echo "$((2#'${1#0b}'))"'
	shift
  done
}