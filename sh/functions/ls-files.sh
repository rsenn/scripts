ls-files()
{
 ([ $# -le 0 ] && set -- .
  while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
      *) break ;;
	esac
  done
  for ARG; do
      ls --color=auto -d $OPTS -- "$ARG"/{,.[!.]}*
  done) 2>/dev/null | filter-test -f| ${SED-sed} "s|^\\./||; s|/\$||"
}
