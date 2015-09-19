modules()
{
    local abs="no" ext="no" dir modules= IFS="
";
    require "fs";
    while :; do
        case $1 in
            -a)
                abs="yes"
            ;;
            -e)
                ext="yes"
            ;;
            -f)
                abs="yes" ext="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    if test "$abs" = yes; then
        fs_recurse "$@";
    else
        for dir in "${@-$shlibdir}";
        do
            ( cd "$dir" && fs_recurse );
        done;
    fi | {
        set --;
        while read module; do
            case $module in
                *.sh | *.bash)
                    if test "$ext" = no; then
                        module="${module%.*}";
                    fi;
                    if ! isin "$module" "$@"; then
                        set -- "$@" "$module";
                        echo "$module";
                    fi
                ;;
            esac;
        done
    }
}
modules() {
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
modules() { 
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ | 
      xml_get a data-url |
      head -n1
  done |
    sed "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}
modules() {
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
modules() { 
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ | 
      xml_get a data-url |
      head -n1
  done |
    sed "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}
modules() {
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
modules() { 
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ | 
      xml_get a data-url |
      head -n1
  done |
    sed "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}
