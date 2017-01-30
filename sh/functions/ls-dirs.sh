ls-dirs() {
 ([ $# -le 0 ] && set -- .
  for ARG; do
    ls --color=auto -d -- "$ARG"/{,.[!.]}*/
  done) | ${SED-sed} "s|^\\./|| ;; s|/\$||"
}
