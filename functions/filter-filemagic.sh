filter-filemagic() {
(EXPR="s,:\\s\\+,: ,p"
  [ $# -gt 0 ]  || set -- ".*"
	 for ARG; do
		 case "$ARG" in
			 "!"*) NOT="!" ARG=${ARG#$NOT} ;;
		   *) NOT="" ;;
		esac
		 EXPR="\\|:\\s\\+${ARG%%|*}|$NOT { $EXPR }"
	 done
  xargs -d "
" file -- | sed -n -u "$EXPR")
}
