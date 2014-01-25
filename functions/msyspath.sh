msyspath() 
{ 
 (MODE=msys;
	while :; do
			case "$1" in 
					-w) MODE=win32; shift ;;
					-m) MODE=mixed; shift ;;
					*) break ;;
			esac;
	done;
	CMD='_msyspath';
	if [ "$1" != "-" -a "$#" -gt 0 ]; then
			CMD="echo \"\$*\" |$CMD";
	fi;
	eval "$CMD";
	exit $?)
}
