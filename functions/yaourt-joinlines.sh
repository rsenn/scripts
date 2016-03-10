yaourt-joinlines() {
(while :; do
   case "$1" in 
		 -R | --remove-repo*) REMOVE_REPO="s|^[^/ ]\\+/||"; shift ;;
		 -V | --remove-ver*) REMOVE_VER="s|^\([^/ ]\\+\)/\([^/ ]\\+\) \([^ ]\) |\1 |"; shift ;;
		 -r | --remove-rat*) REMOVE_RATING="s|)\s\+\(([^)]\+)\)|)|"; shift ;;
		 *) break ;;
		esac
	done

  EXPR="\\|^[^/ ]\\+/[^/ ]\\+\\s| { :lp; N; /\\n\\s[^\\n]*$/ { s|\\n\\s\\+| - |; b lp }; s,\\n\\s\\+, - ,g; ${REMOVE_REPO}; ${REMOVE_VER}; ${REMOVE_RAT}; :lp2; /\\n/ { P; D; b lp2; }; b lp }"
  exec sed -e "$EXPR" "$@")
} 
