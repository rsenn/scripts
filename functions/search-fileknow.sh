search-fileknow () 
{ 
  . require.sh
  require url
  for Q; do
   (Q=${Q// /-}
	Q=$(url_encode_args "=$Q")
	SURL="http://fileknow.org/${Q#=}"
	URLS=$SURL
	PIPE="$(basename "${0#-}" .sh)-$$"
	trap 'rm -f "$PIPE"' EXIT INT QUIT
	rm -f "$PIPE"; mkfifo "$PIPE"
	
	while [ $(countv URLS) -gt 0 ]; do
	  (set -x; dlynx.sh "$(indexv URLS 0)")	 >"$PIPE" &
	  shiftv URLS
	  while read -r LINE; do
		case "$LINE" in
		  */download/*) pushv DLS "$LINE" ;;
		  *#[0-9]*) 		  
		    OFFS=${LINE##*\#}
		    OFFS=$(( (OFFS - 1) * 10 ))
		    pushv URLS "$SURL?n=$OFFS" ;;
		  *) continue ;;
		esac
        echo "$LINE"
	  done <"$PIPE"
	  wait 
	done) || return $?	  
  done 
}
