index-tar()
{ 
    ( while :; do
      case "$1" in
         -s | --save ) SAVE=true; shift ;;
         -d | --debug ) DEBUG=true; shift ;;
         *) break ;; 
         esac
         done

FILTERCMD='sed "s,^\./,,"'
if [ $# -gt 1 ]; then
        FILTERCMD=${FILTERCMD:+$FILTERCMD'|'}'sed "s|^|$ARG:|"';
    else
        unset FILTERCMD;
    fi
    [ "$SAVE" = true ] && OUTPUT="\${ARG%.tar*}.list"
    
    CMD="tar -tf \"\$ARG\" 2>/dev/null ${FILTERCMD+|$FILTERCMD}${OUTPUT:+>$OUTPUT}"
    [ "$DEBUG" = true ] && DBG="echo \"tar -tf \$ARG${OUTPUT:+ >$OUTPUT}\"; "
   eval "for ARG; do $DBG eval \"\$CMD\" ; done")
}
