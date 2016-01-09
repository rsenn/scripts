sf-get-git-repos() {
  require xml
 (for ARG; do
    curl -s  "http://sourceforge.net/p/$ARG/code-git/ci/master/tree/" |
      xml_get a data-url |
      head -n1
  done |
    ${SED-sed} "s|-git\$|| ;; s|-code\$||" |
    addsuffix "-git")
}
