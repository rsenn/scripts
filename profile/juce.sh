for x in /*/*{JUCE,Juce,juce}*; do 
  [ -d "$x" ] || continue
  pathremove "$x" 
  pathmunge "$x" after
done

INTROJUCER_APP=$(IFS=:; for DIR in $PATH; do  set "$DIR/"*Introjucer.app ; ls -d -- "$@" 2>/dev/null; done)
[ -e "$INTROJUCER_APP" -a -x "$INTROJUCER_APP" ] || unset INTROJUCER_APP

dq='"'
dollar='$'
backspace="\\"

Introjucer() {
  (CMD='open -a "$INTROJUCER_APP" "$@" &'
  ECHO=${CMD//"$dq"/"$backspace$dq"}
  ECHO=" echo \"$ECHO\""
  [ "$DEBUG" = true ] && eval "$ECHO 1>&2"
   eval "${CMD}")
}
