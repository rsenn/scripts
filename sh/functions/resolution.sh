resolution() {
 (EXPR='/Width/N
/pixels/ {
  s|Width=\([0-9]\+\)\s*pixels| \1|g
  s|Height=\([0-9]\+\)\s*pixels| \1|g
  s|[^\n]*:\s\+\([^\n:]*\)$|\1|
  s|\r\n|\n|g
  s|^\s\+||
  s| *\n *|x|p
}'; while [ $# -gt 0 ] ; do case "$1" in
    -m | --mult*) CMD="echo \$(($1 * $2))"; shift ;; 
    *) break ;;
  esac
  done
  mminfo "$@" | grep -v '^Original' | ${SED-sed} -n "$EXPR")
}                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                     
