yaourt-joinlines() {
(while :; do
   case "$1" in 
		 -R | --remove-repo*) REMOVE_REPO="s|^[^/ ]\\+/||"; shift ;;
		 -V | --remove-ver*) REMOVE_VER="s|^\([^/ ]\\+\)/\([^/ ]\\+\) \([^ ]\\+\) |\\1/\\2 |"; shift ;;
		 -I | --no*inst*) NO_INSTALLED="/\\[installed/!"; shift ;;
		 -r | --remove-rat*) REMOVE_RATING="s|)\s\+\(([^)]\+)\)|) |"; shift ;;
		 -n | --remove-num*) REMOVE_NUM="s|^\([^/ ]\\+\)/\([^/ ]\\+\) \([^ ]\\+\) \(([^)]\+)\)|\\1/\\2 \\3|"; shift ;;
		 -s | --*sep*) COLSEP="$2";  shift 2 ;;
		 *) break ;;
		esac
	done

  EXPR="\\|^[^/ ]\\+/[^/ ]\\+\\s| { :lp; ${REMOVE_RATING}; ${REMOVE_NUM}; ${REMOVE_VER}; ${REMOVE_REPO}; N; /\\n\\s[^\\n]*$/ { s,\\n\\s\\+,${COLSEP- - },; b lp }; s,\\n\\s\\+, - ,g; :lp2; /\\n/ { s,[^[:print:]\\n],,g; ${NO_INSTALLED} P; D; b  lp2; }; b lp }"
  exec sed -e "$EXPR" "$@")
} 
