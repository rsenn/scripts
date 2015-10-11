pathtool() {
 (EXPR= F=
  while :; do
    case "$1" in
      -w | -m | -u) F="$1"; shift ;;
      *) break ;
    esac
  done
  [ $# -gt 0 ] && exec <<<"$*"

  case "$F" in
    -w | -m) ROOTS=$(mount | sed -n '\|/cygdrive|! s,^\([^ ]*\) on \(.*\) type.*,\\|^.:|! { \\|^/cygdrive|! { s|^\2|\1| } };,p') ;;
    *) ROOTS=$( mount  | sed -n '\|/cygdrive|! s,^\([^ ]*\) on \(.*\) type.*,\1\n\2,p' | sed '/^.:/ { s|/|\[\\\\/\]|g; N; s,\n,|, ; s,.*,s|^&|; , }') ;;
  esac

  EXPR="${EXPR:+$EXPR ;; }$ROOTS"

  case "$F" in
	-w | -m) EXPR="${EXPR:+$EXPR ;; }s|/cygdrive/\(.\)/\(.*\)|\1:/\2|" ;;
	*) EXPR="${EXPR:+$EXPR ;; }s|^\(.\):|/cygdrive/\1|" ;;
  esac


  case "$F" in
	-m | -u) EXPR="${EXPR:+$EXPR ;; }s|\\\\|/|g" ;;
	-w) EXPR="${EXPR:+$EXPR ;; }s|/|\\\\|g" ;;
  esac

  [ "$DEBUG" = true ] && echo "+ sed '$EXPR'"
  sed "$EXPR")
}
