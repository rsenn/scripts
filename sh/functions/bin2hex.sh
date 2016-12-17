bin2hex() {
  while [ $# -gt 0 ]; do
	eval 'printf "0x%02x\n" "$((2#'${1#0b}'))"'
	shift
  done
}