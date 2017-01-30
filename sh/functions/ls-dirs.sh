ls-dirs() {
 ([ $# -le 0 ] && set -- .
  for ARG; do
    ls --color=auto -d -- "$ARG"/{,.[!.]}*/
  done) 2>/dev/null | ${SED-sed} "s|^\\./|| ;; s|/\$||"
}
