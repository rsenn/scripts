 subst-build-cmd() {
  : ${vs=2013} ${vc=12}
  	
	s() {
	  sed 's,20[01][0-9],'$vs',g ;; s, [8-9] , '$vc' ,g  ;; s, 1[0124] , '$vc' ,g' "$@"
	}
	for x in ${@:-build/vs2008-*/build.cmd}; do
		y=$(s <<<"$x")
		mkdir -p "$(dirname "$y")"
		s < "$x" >"$y"
		echo "$y"
	done
}


