index-dir() {
  [ -z "$*" ] && set -- .
 ([ "$(uname -m)" = "x86_64" ] && : ${R64="64"}
  while :; do
    case "$1" in
      -u | -update | --update) UPDATE="true"; shift ;;
      *) break ;;
    esac
  done
  for ARG in "$@"; do
   (cd "$ARG"
      LIST="$PWD/files.list"
	  if [ ! -w "$PWD" ]; then
		echo "Cannot write to $PWD ..." 1>&2
		exit
	  fi
	  if [ "$UPDATE" = true -a -s "$LIST" ]; then
	    echo "$LIST"
	    exit
	  fi
	  echo "Indexing directory $PWD ..." 1>&2
	  TEMP=`mktemp "/tmp/XXXXXX.list"`
	  trap 'rm -f "$TEMP"; unset TEMP' EXIT
	 (if type list-r${R64} 2> /dev/null > /dev/null; then
		list-r${R64} 2> /dev/null
	  else
			  list-recursive
	  fi) >"$TEMP"
	 (install -m 644 "$TEMP" "$LIST" && rm -f "$TEMP" ) || mv -f "$TEMP" "$LIST"
	  echo "$LIST")
  done)
}
