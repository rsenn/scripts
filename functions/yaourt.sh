yaourt-pkgnames() {
 (NAME='\([^ \t/]\+\)'
 sed -n "s|^${NAME}/${NAME}\s\+\(.*\)|\2|p")
}

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

yaourt-cutver() {
 (NAME='\([^ \t/]\+\)'
 sed "s|^${NAME}/${NAME}\s\+\([^ \t]\+\)\s\+\(.*\)|\1/\2 \4|")
}

yaourt-cutnum() {
 #(NAME='\([^ \t/]\+\)';  sed "s|^${NAME}/${NAME}\s\+\(.*\)\s\+\(([0-9]\+)\)\(.*\)|\1/\2 \3 \5|")
 sed "s|\s\+\(([0-9]\+)\)\(.*\)| \2|"
}
