sf-get-cvs-modules() {
 (PREFIX="cvs -z3 -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG co -P "; for ARG; do CMD="curl -s http://$ARG.cvs.sourceforge.net/viewvc/$ARG/ | sed -n \"s|^\\([^<>/]\+\\)/</a>\$|$PREFIX\\1|p\""; : echo "CMD: $CMD" 1>&2; eval "$CMD"; done)
}
sf-get-svn-modules() { 
  require xml
 (for ARG; do curl -s "http://sourceforge.net/p/$ARG/code/HEAD/tree/" |xml_get a data-url; done)
}
sf-get-git-repos() {
  require xml
 (for ARG; do curl -s  "http://sourceforge.net/p/$ARG/code-git/ci/master/tree/"  |xml_get a data-url; done)
}

