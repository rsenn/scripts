resolution() {
 (	EXPR='/Width/N; /pixels/ { s,[^=\n]*=\([0-9]\+\)\s*pixels,\1,g; s,\n,x,p }'; while [ $# -gt 0 ] ; do case "$1" in
    -m | --mult*) CMD="echo \$(($1 * $2))"; shift ;; 
    *) break ;;
  esac
  done
  mminfo "$@"|${SED-sed} -n "$EXPR")
}                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                     