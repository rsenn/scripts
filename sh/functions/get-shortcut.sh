get-shortcut()
{
  (for SHORTCUT; do
  (    set -- TARGET=-t WDIR=-g ARGS=-r ICON=-i ICONOFFSET=-j DESC=-d SHOWCMD=-s
  O=
   for A; do
     O="${O:+$O
}${A%%=*}=$(readshortcut ${A##*=} "$SHORTCUT")"
     done
     echo "$O")
     done)
}
