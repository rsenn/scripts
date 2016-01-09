sf-get-cvs-modules() {
 (CVSCMD="cvs -z3 -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG co"
#  CVSPASS="cvs -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG login"
CVSPASS='echo "${GREP-grep} -q @$ARG.cvs.sourceforge.net ~/.cvspass 2>/dev/null || cat <<\\EOF >>~/.cvspass
\1 :pserver:anonymous@$ARG.cvs.sourceforge.net:2401/cvsroot/$ARG A
EOF"'
  for ARG; do
    CMD="curl -s http://$ARG.cvs.sourceforge.net/viewvc/$ARG/ | ${SED-sed} -n \"s|^\\([^<>/]\+\\)/</a>\$|\\1|p\""
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
