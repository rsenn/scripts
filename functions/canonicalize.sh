canonicalize()
{
  (IFS="
 -"
   while :; do
   case "$1" in
     -l|--lowercase) LOWERCASE=true; shift ;;
     -m=|--maxlen=) MAXLEN="${1#*=}"; shift ;;
     -m|--maxlen) MAXLEN="$2"; shift 2 ;;
     *) break ;;
     esac
   done
     : ${MAXLEN:=4095}
 
   CMD="sed 's,[^A-Za-z0-9],-,g'|sed 's,-\+,-,g ;; s,^-\+,, ;; s,-\+\$,,'"
   [ "$LOWERCASE" = true ] && CMD="$CMD|tr [:{upper,lower}:]"
   #[ $# -gt 0 ] && CMD='set -- \$(IFS=" "; echo "$*"|'$CMD')'
   
   set -- $(echo "$*"|eval "$CMD")
   
   unset OUT
   
   while [ $# -gt 0 ]; do
      [ -z "$1" ] && continue
     NEWOUT="${OUT:+$OUT-}$1"
     [ ${#NEWOUT} -gt ${MAXLEN} ] && break
     OUT="$NEWOUT"
     shift
   done
   
   echo "$OUT"  
   
   )
}
