#!/bin/sh

IFS="
"
pushv_unique() {
	local v=$1 s IFS=${IFS%${IFS#?}};
	shift;
	for s in "$@";do
			if eval "! isin \$s \${$v}"; then
					pushv "$v" "$s";
			else
					return 1;
			fi;
	done
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
isin()
{
    ( needle="$1";
    while [ "$#" -gt 1 ]; do
        shift;
        test "$needle" = "$1" && exit 0;
    done;
    exit 1 )
}

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
#	echo "$LIBDIRS"
}

search_in_libdirs() {
  unset O
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
	: ${O:=$F}
}
get_pe_deps() {
 ([ $# -gt 1 ] && PFX='$ARG: '
  CMD='for ARG; do "${OBJDUMP:-objdump}" -x "$ARG" |sed -n "s|.*DLL\sName:\s\+|'$PFX'|p"; done'
  eval "$CMD")
}
get_deps() {


	F=$(file "$1")
  R=$(realpath "$1")
  [ -z "$I" ] && echo "$R:"


	unset D

	CMD="case \"\$F\" in
		*:\ *ELF*) readelf -a \"\$1\" | sed -n 's,.*Shared library:\s\+\[\(.*\)\].*,\1,p'; test -n \"\$D\" || D=strings \"\$1\" |grep '^lib.*\.so'  ;;
  	*:\ PE*executable*) #strings \"\$1\" |sed -n '/\.[Dd][Ll][Ll]\$/ { /^[[:upper:]]\+32\./! { /^[Mm][Ss][Vv][Cc][^.]*\./! { /^KERNEL32\....\$/! p } } }'
  	get_pe_deps \"\$1\" #| grep -viE '^(advapi32|atidxx32|avicap32|avifil32|avmc2032|cfgmgr32|cimwin32|clfsw32|cmcfg32|cmdial32|cmpbk32|cnb_0332|cnbbr332|cnbp_332|comctl32|comdlg32|crypt32|ctl3d32|dciman32|diapi232|fxsext32|fxsxp32|gdi32|glmf32|glu32|icm32|iedkcs32|igdumd32|imm32|ir32_32|ir50_32|iyuv_32|kernel32|ktmw32|lz32|mapi32|mciavi32|mciqtz32|msacm32|mscat32|mscpxl32|msimg32|msorcl32|msrle32|mssign32|mssip32|msvfw32|msvidc32|netapi32|nvcuda32|nvoglv32|odbc32|odbccp32|odbccr32|odbccu32|odbcji32|odbcjt32|oddbse32|odexl32|odfox32|odpdx32|odtext32|ole32|oleaut32|olecli32|oledb32|olepro32|olesvr32|olethk32|openal32|opengl32|p17apo32|rasapi32|riched32|rshx32|secur32|shell32|sqlsrv32|tapi32|twain_32|twlay32|txfw32|user32|vbajet32|vfwwdm32|wab32|wldap32|wow32|ws2_32|wsnmp32|wsock32|wtsapi32|xwtpw32|wnaspi32)\.'
    ;;
	  *:\ Mach-O*) strings \"\$1\" |grep -i '\.dylib\$' ;;
  esac 2>/dev/null"
  
  CMD=$CMD' | grep -viE "(^|/|\\\\)$DLLS\$"'
  
  D=$(eval "$CMD")


  if [ -z "$D" ]; then
    : I="$I  " output "No library deps" 2
  else

    for F in $D; do
      O=$(type "$F" 2>/dev/null); O=${O##*" is "}; [ -f "$O" ] && O=$(cygpath -am "$O")
			I="$I  " A="$O" output "$F"
			IFS="|" pushv_unique DLLS "$F"
		 [ -n "$O" -a -f "$O" ] && I="$I  " get_deps "$O"

		done

#		for F in $D; do
#      O=$(type "$F" 2>/dev/null); O=${O##*" is "}
#		 #search_in_libdirs
#		 [ -n "$O" -a -f "$O" ] && I="$I  " get_deps "$O"
#		 done
   fi
}

main() {
	while :; do
		case "$1" in
		  -r | --recursive) RECURSIVE=true; shift ;;
			*) break ;;
		esac
	done
 
  if [ $# -gt 1 ]; then
		OUTPUT_CMD='for LINE in $1; do echo "$ARG: $LINE"; done'
	else
    OUTPUT_CMD='[ -z "$A" ]  && { A=$(type "$1" 2>/dev/null); A=${A##*" is "}; }; printf "%s%-$((40 - ${#I}))s%s\n" "$I" "${P:+$P: }$1" "${A:+ -> "$A"}"'
	fi
  OUTPUT_CMD='test "$2" = 2 && exec 1>&2; '$OUTPUT_CMD
	eval 'output() { ('$OUTPUT_CMD'); }'

  get_libdirs

  IFS="$IFS;:"
  add_libdir $PATH
#  for DIR in $PATH; do
#    ls -d "$DIR"/*.dll 2>/dev/null >/dev/null &&  add_libdir="$DIR"
#  done
  [ "$DEBUG" = true ] && echo "LIBDIRS="$LIBDIRS 1>&2


	for ARG; do
	  get_deps "$ARG"
  done
}

main "$@"
