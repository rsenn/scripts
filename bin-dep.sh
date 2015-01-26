#!/bin/sh

IFS="
"

get_deps() {

	F=$(file "$1")

	case "$F" in
		*:\ *ELF*) D=`readelf -a "$1" | sed -n 's,.*Shared library:\s\+\[\(.*\)\].*,\1,p'`; test -n "$D" || D=`strings "$1" |grep '^lib.*\.so'`  ;;
	  *:\ PE*executable*) D=` strings "$1" |sed -n '/\.[Dd][Ll][Ll]$/ { /^KERNEL32\....$/! p }'` ;;
	  *:\ Mach-O*) D=` strings "$1" |grep -i '\.dylib$'` ;;
  esac 2>/dev/null

  if [ -z "$D" ]; then
    output "No library deps" 2
  else
	  output "$D"
  fi
}

main() {
	while :; do
		case "$1" in
			*) break ;;
		esac
	done
 
  if [ $# -gt 1 ]; then
		OUTPUT_CMD='for LINE in $1; do echo "$ARG: $LINE"; done'
	else
		OUTPUT_CMD='echo "$*"'
	fi
  OUTPUT_CMD='test "$2" = 2 && exec 1>&2; '$OUTPUT_CMD
	eval 'output() { ('$OUTPUT_CMD'); }'

	for ARG; do
	  get_deps "$ARG"
  done
}

main "$@"
