yaourt-joinlines() {
 (while :; do 
   case "$1" in
		-n | --num*) CUT_NUM=true ;;
		-s | --state) CUT_STATE=true ;;
		*) break ;;
		esac 
		shift
	done
		while read -r LINE; do
    case "$LINE" in
			"   "*) PKG="${PKG:+$PKG - }${LINE#    }" ;;
      *) 
				[ -n "$PKG" ] && echo "$PKG"
				PKG="${LINE}"
				${CUT_STATE:-false} && 
				PKG="${PKG% \[*\]}"
				${CUT_NUM:-false} && PKG="${PKG% (*)}"
				;;
		esac
	done
	[ -n "$PKG" ] && echo "$PKG")
}
