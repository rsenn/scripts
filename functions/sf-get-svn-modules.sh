sf-get-svn-modules() { 
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ | 
      xml_get a data-url |
      head -n1
  done |
    sed "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}
