DIETPATH="/opt/diet/bin"
case "$PATH" in
  *:$DIETPATH | *:$DIETPATH:* | $DIETPATH:*) ;;
  *)  PATH="$PATH:$DIETPATH" ;;
esac

