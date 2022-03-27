pathlist() {
 (eval 'IFS=:; set -- ${'${1-PATH}'}'
  IFS="
"; echo "$*")
}
