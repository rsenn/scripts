#!/bin/sh

BS="\\"
IFS="
"
find_prog() {
  PROG=$(type "$1" | ${SED-sed} -n "s|\(.*\) is \(.*\)|\2|p")
  test -n "$PROG" -a -e "$PROG" && echo "${PROG##*/}"
}

CACLS=`find_prog cacls`
ICACLS=`find_prog icacls`
TAKEOWN=`find_prog takeown`

main() {
	: ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}

  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      -g | --group) GRP="$2"; shift 2 ;; -g=* | --group=*) GRP="${1#*=}"; shift ;; -g*) GRP="${1#-?}"; shift ;;
      -u | --user) USR="$2"; shift 2 ;; -u=* | --user=*) USR="${1#*=}"; shift ;; -u*) USR="${1#-?}"; shift ;;
      *) break ;;
    esac
  done

	case ${OS} in
		[Mm][Ss][Yy][Ss]*) PATHTOOL=msyspath
			msyspath() {
				echo "msyspath: $@" 1>&2
				case "$1" in
					?:*) echo "/${1%%:*}${1#?:}" ;;
					*) echo "$*" ;;
				esac
			}
		 ;;
		[Cc]ygwin)
			DRIVEPREFIX=/cygdrive
      PATHTOOL=cygpath
		;;
	esac
    if [ -n "$ICACLS" ]; then
      [ -n "$USR" ] && CMD="$ICACLS \"\$P\" /setowner \"\$USR\" /T" ||  CMD="$ICACLS \"\$P\" /reset /T"
    elif [ -n "$CACLS" ]; then
      CMD="$CACLS \"\$P\" /E /T /C${USR:+ /G \"\$USR\"${GRP:+:\"\$GRP\"}}"
    elif [ -n "$TAKEOWN" ]; then
      CMD="$TAKEOWN /F \"\$P\" /R"
    else
      echo "No command for permission change (e.g. ICACLS, CACLS, TAKEOWN)" 1>&2
      exit 2
    fi
	
 for ARG; do
   P=`${PATHTOOL:-echo} ${PATHTOOL:+-w} "$ARG"`
   
   if [ "$DEBUG" = true ]; then
     echo "P: $P" 1>&2
     echo "CMD: ${CMD}" 1>&2
   fi
    eval "(set -x; $CMD 2>&1)"
    done
     	
}

main "$@"
