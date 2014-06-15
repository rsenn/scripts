#!/bin/sh

: ${SI_HANDLE="`cygpath "$PROGRAMFILES"`/SysInternals/handle.exe"}

_lsof()
{
	(IFS=" "
  _PID="$1"
  PNAME="${2:-$1}"
                printf "%-10s %-5s %-10s %-5s %s\n" NAME PID TYPE VALUE
	"${SI_HANDLE:-handle.exe}" -a ${1:+-p "$1"} |
	while read -r _LINE; do
		_HANDLE=${_LINE%%": "*}
		_LINE=${_LINE#*"$_HANDLE: "}
		set -- $_LINE
		case "$1" in
			Directory) TYPE="dir" ; shift ;;
				File) TYPE="file"; shift 2 
          case "$*" in
            "\\"*) if [ -e /proc/sys"$*" ]; then
              set -- "$(cygpath /proc/sys"$*")"
            fi ;;
        esac
            ;;
				Key) 
					TYPE="registry"; shift 
          IFS="\\"
          set -- $*
          R="$1"
          shift
          IFS="/"
          case "$R" in
            HKCR) set "HKEY_CLASSES_ROOT/$*" ;;
            HKCC) set "HKEY_CURRENT_CONFIG/$*" ;;
            HKCU) set "HKEY_CURRENT_USER/$*" ;;
            HKLM) set "HKEY_LOCAL_MACHINE/$*" ;;
          HKU) set "HKEY_USERS/$*" ;;
        esac
        set /proc/registry/"$*"
        IFS=" "
        

			;; 
		         *) continue ;;
		 esac
                printf "%-10s %-5d %-10s %-5s %s\n" "$PNAME" "$_PID" "$TYPE" "$_HANDLE" "$*"
	done	 )
}


ps -aW | 
while read -r _PID _PPID _PGID _WINPID _TTY _UID _STIME _COMMAND; do
  case "$_COMMAND" in
	   *"<defunct>"*) continue ;;
   esac 
 _lsof "$_PID" "${_COMMAND##*[/\\]}"
  done
