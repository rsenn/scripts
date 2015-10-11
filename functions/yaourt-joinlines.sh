yaourt-joinlines() {
 (while :; do
   case "$1" in
    -i | --installed) P_INSTALLED=yes ;;
    -I | --not-installed) P_INSTALLED=no ;;
    -n | --num*) CUT_NUM=true ;;
    -s | --state) CUT_STATE=true ;;
    *) break ;;
    esac
    shift
  done
    PKG= INSTALLED=
    P_CMD='if [ -n "$PKG"'${P_INSTALLED:+' -a "$P_INSTALLED" = "$INSTALLED"'}' ]; then
        echo "$PKG"
      fi'
    eval "p() { $P_CMD; }"
    while read -r LINE; do
    case "$LINE" in
      "   "*) PKG="${PKG:+$PKG - }${LINE#    }" ;;
      *)
        p
        PKG="${LINE}"
        ${CUT_STATE:-false} &&
        #PKG="${PKG% \[*\]}"
        case "$PKG" in
          *"[installed"*) INSTALLED="true" ;;
          *) INSTALLED="false" ;;
        esac

        PKG="${PKG/ \[*\]/}"
        ${CUT_NUM:-false} && PKG="${PKG% (*)}"
        ;;
    esac
  done
  p)
}
