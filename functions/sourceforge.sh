sf-get-cvs-modules() {
 (CVSCMD="cvs -z3 -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG co"
#  CVSPASS="cvs -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG login"
CVSPASS='echo "grep -q @$ARG.cvs.sourceforge.net ~/.cvspass 2>/dev/null || cat <<\\EOF >>~/.cvspass
\1 :pserver:anonymous@$ARG.cvs.sourceforge.net:2401/cvsroot/$ARG A
EOF"'
  for ARG; do
    CMD="curl -s http://$ARG.cvs.sourceforge.net/viewvc/$ARG/ | sed -n \"s|^\\([^<>/]\+\\)/</a>\$|\\1|p\""
	 (set -- $(eval "$CMD")
		test $# -gt 1 && DSTDIR="${ARG}-cvs/\${MODULE}" || DSTDIR="${ARG}-cvs"
		CMD="${CVSCMD} -d ${DSTDIR} -P \${MODULE}"
		#[ -n "$DSTDIR" ] && CMD="(cd ${DSTDIR%/} && $CMD)"
		CMD="echo \"$CMD\""
		
		CMD="for MODULE; do $CMD; done"
		[ -n "$DSTDIR" ] && CMD="echo \"mkdir -p ${DSTDIR%/}\"; $CMD"
		[ -n "$CVSPASS" ] && CMD="$CVSPASS; $CMD"
		[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
		eval "$CMD")
  done)
}

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

sf-get-git-repos() {
  require xml
 (for ARG; do
    curl -s  "http://sourceforge.net/p/$ARG/code-git/ci/master/tree/" |
			xml_get a data-url |
			head -n1
  done |
    sed "s|-git\$|| ;; s|-code\$||" |
    addsuffix "-git")
}