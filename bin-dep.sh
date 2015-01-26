#!/bin/sh

IFS="
"
get_libdirs() {
	LIBDIRS=""
	add_libdir() {
		for ARG; do test -d "$ARG" &&
		LIBDIRS="${LIBDIRS:+$LIBDIRS
}${ARG%/}"
    done
  }
	case "$1" in
		*/usr/*) add_libdir ${1%/usr/*}{/usr/local,/usr,}/lib{64,,32}{,/*linux*/} ;;
		*/*bin/*) add_libdir ${1%/*bin/*}{/usr/local,/usr,}/lib{64,,32}{,/*linux*/} ;;
  esac
	echo "$LIBDIRS"
}

get_deps() {

	F=$(file "$1")
	unset D

	case "$F" in
		*:\ *ELF*) D=`readelf -a "$1" | sed -n 's,.*Shared library:\s\+\[\(.*\)\].*,\1,p'`; test -n "$D" || D=`strings "$1" |grep '^lib.*\.so'`  ;;
	  *:\ PE*executable*) D=` strings "$1" |sed -n '/\.[Dd][Ll][Ll]$/ { /^KERNEL32\....$/! p }'` ;;
	  *:\ Mach-O*) D=` strings "$1" |grep -i '\.dylib$'` ;;
  esac 2>/dev/null

  if [ -z "$D" ]; then
    output "No library deps" 2
  else

		LIBDIRS=`get_libdirs "$1"` 

	  for F in $D; do
			case "$F" in
				*/*) ;;
					*)
					for LIBDIR in $LIBDIRS; do 
						if [ -e "$LIBDIR/$F" ]; then
							O="$LIBDIR/$F"
							break
						fi
					done
			  ;;
		  esac
			output "${O:-$F}"
		done
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
