make-cfg-sh() { 
 (for ARG in "${@:-./configure}"; do
     
  "$ARG" --help  |sed -n '/--help/d; /--cache-file/d; /--srcdir/d; /^\s*--/   {
  /-[[:upper:]]/q ; s|^\s*||; s|\s.*||;  s|.*|  & \\|;   s|\s*||; p
}
' |while read -r LINE; do
					case "$LINE" in
						*=*) OPT=${LINE%%=*}; VALUE=${LINE#*=} ;;
						*) OPT="$LINE" ;;
					esac
					VAR=$(tr [[:upper:]] [[:lower:]] <<<"${VALUE//"-"/"_"}")
					VAR=${VAR%" "}
					echo "$OPT${VALUE:+=\${$VAR}}"
  done
  
  done)
}
