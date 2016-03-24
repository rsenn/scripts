MYDIR=` dirname "$0" ` 

[ $# -ge 1 ] ||set --  "$HOME"

for x in "$MYDIR"/bash_*.sh; do
  b=`basename "$x" .sh` 
 for y; do 
   case "$b" in
     *_profile) CMD="grep -vE \"(^\\s*#[^ !]|^\\s*#.*[\\\"'(){}]|^\\s*#.*esac|^\\s*#.*done|^\\s*#.*unset|^\\s*#\s*for\s|^\\s*#.*;;)\" <\"$x\" >\"$y/.${b%.sh}\"" ;;
     *) CMD="cp -f \"$x\" \"$y/.${b%.sh}\"" ;;
   esac
   CMD="$CMD || exit \$?"
   
   eval "$CMD" && echo "$y/.${b%.sh}" #1>&2
  done
done
