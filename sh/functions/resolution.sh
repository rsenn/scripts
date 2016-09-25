resolution()                                                                                                                                                                                                                                                                         
{                                                                                                                                                                                                                                                                                    
 (while [ $# -gt 0 ] ; do case "$1" in
    -m | --mult*) RS="*" ; shift ;; 
    *) break ;;
  esac
  done

EXPR="/Width\s*: / { N; /Height\s*:/ { s,Width\s*:,, ; s,[^:\n0-9]\+: \+\([^:]*\)\$,\1,g; s|^\s*||; s|\([0-9]\)\s\+\([0-9]\)|\1\2|g; s|\s*pixels||g;  s|\n|${RS-x}|g; p } }"
  minfo "$@"|${SED-sed} -n "$EXPR"
  )
}                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                     
