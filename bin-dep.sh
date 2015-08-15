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
	*:\ PE*executable*) D=` strings "$1" |sed -n '/\.[Dd][Ll][Ll]$/ { /^[[:upper:]]\+32\./! { /^[Mm][Ss][Vv][Cc][^.]*\./! { /^KERNEL32\....$/! p } } }' | grep -viE '^(advapi32|atidxx32|avicap32|avifil32|avmc2032|cfgmgr32|cimwin32|clfsw32|cmcfg32|cmdial32|cmpbk32|cnb_0332|cnbbr332|cnbp_332|comctl32|comdlg32|crypt32|ctl3d32|dciman32|diapi232|fxsext32|fxsxp32|gdi32|glmf32|glu32|icm32|iedkcs32|igdumd32|imm32|ir32_32|ir50_32|iyuv_32|kernel32|ktmw32|lz32|mapi32|mciavi32|mciqtz32|msacm32|mscat32|mscpxl32|msimg32|msorcl32|msrle32|mssign32|mssip32|msvfw32|msvidc32|netapi32|nvcuda32|nvoglv32|odbc32|odbccp32|odbccr32|odbccu32|odbcji32|odbcjt32|oddbse32|odexl32|odfox32|odpdx32|odtext32|ole32|oleaut32|olecli32|oledb32|olepro32|olesvr32|olethk32|openal32|opengl32|p17apo32|rasapi32|riched32|rshx32|secur32|shell32|sqlsrv32|tapi32|twain_32|twlay32|txfw32|user32|vbajet32|vfwwdm32|wab32|wldap32|wow32|ws2_32|wsnmp32|wsock32|wtsapi32|xwtpw32|wnaspi32)\.'` ;;
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
