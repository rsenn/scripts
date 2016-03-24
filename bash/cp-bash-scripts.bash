MYDIR=` dirname "$0" ` 

[ $# -ge 1 ] ||set --  "$HOME"

for x in "$MYDIR"/bash_*.bash; do
  b=`basename "$x" .bash` 
 for y; do 
   case "$b" in
     *_profile) CMD="grep -vE \"(^\\s*#[^ !]|^\\s*#.*[\\\"'(){}]|^\\s*#.*esac|^\\s*#.*done|^\\s*#.*unset|^\\s*#\s*for\s|^\\s*#.*;;)\" <\"$x\" >\"$y/.${b%.bash}\"" ;;
     *) CMD="cp -f \"$x\" \"$y/.${b%.bash}\"" ;;
   esac
   CMD="$CMD || exit \$?"
   
   eval "$CMD" && echo "Wrote '$y/.${b%.bash}'." #1>&2
  done
done
