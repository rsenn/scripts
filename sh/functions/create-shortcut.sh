create-shortcut()
{
 (declare "$@"
  (set -x; mkshortcut ${ARGS:+-a
"$ARGS"} ${ICON:+-i
"$ICON"} ${ICONOFFSET:+-j
"$ICONOFFSET"} ${DESC:+-d
"$DESC"} ${NAME:+-n
"$NAME"} ${WDIR:+-w
"$WDIR"} \
"$TARGET")
  )
}
