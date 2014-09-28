x-fn() 
{ 
 (MATCH=p
  NOMATCH=D
  while :; do
    case "$1" in
      -1 | --oneline) XTRA="$XTRA; s,\s\+, ,g" ;;
      -d | --delete) MATCH=d; NOMATCH='P;D;' ;;
      *) break ;;
    esac
    shift
  done
  
  FN="$1";
  shift;
  #: ${XTRA="$XTRA; s/^/-->/; s/\n/\n-->/g"}
  sed " :lp0 
   \$ { /\n/! $NOMATCH; } 
    N
    /\n/! b lp0

    /$FN[^\n]*\$/ {

      /)/ b endargs
      :lp1
      N
      /)/! b lp1
      
      :endargs

      /).*;\s*$/ b endfn

      :lp2
      N
      /\n}[ \t]*$/! b lp2
      :endfn
      $XTRA
      $MATCH

      :endlp
      d
      n
      b endlp
      q
    }
    $NOMATCH
    b lp0

  " "$@")
}
