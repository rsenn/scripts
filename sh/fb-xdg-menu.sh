#!/bin/sh

THISDIR=$(dirname "$0")

case "$THISDIR" in
  *fluxbox) cd "$THISDIR" ;;
  *) cd  "$HOME/.fluxbox" ;;
esac

fbmenugen
xdgmenumaker -f fluxbox "$@" \
  2>/dev/null \
  >xdgmenu

sed '/submenu.*Appli/d; /^\[end/d' \
  -i xdgmenu

sed "/\[encoding/ { :lp; N; /separator/!  b lp
 s|\n *\[exec.*||
 r./favorites
 a\
[separator]
 r./xdgmenu
 a\
[separator]
 }

 /submenu.*Access/ i\
[submenu] (FbAppMenu)
 
 /submenu.*Fluxbox.menu/ i\
[end] 
 " \
  -i menu



