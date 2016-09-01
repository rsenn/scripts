svgsize() {
(while :; do
   case "$1" in
		-xy | --xy) XY=true; shift ;;
*) break ;;
esac
done

  sed -n  's,.*viewBox=[^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\).*,\1 \2 \3 \4,p' "$@" | 
	(IFS=" "; while  read -r x y w h; do

	if [ "$XY" = true ]; then
			echo x$(expr "$w" - "$x")Y$(expr "$h" - "$y")
		else
			echo $(expr "$w" - "$x") $(expr "$h" - "$y")
	fi
	done)
	)
}

