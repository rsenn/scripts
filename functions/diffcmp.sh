diffcmp()
{
 (unset OPTS; while :; do
    case "$1" in
      --) shift; break ;;
      -*) OPTS="${OPTS+$OPTS$IFS}$1"; shift ;;
      *) break ;;
    esac
  done
  unset DIREXPR
  for ARG; do
    test -d "$ARG" || ARG=`dirname "$ARG"`
    DIREXPR="${DIREXPR+$DIREXPR ;; }s|^${ARG%/}/||"
  done

  diff $OPTS "$@" |
  sed -n \
    -e 's/^Binary files \(.*\) and \(.*\) differ/\1\n\2/p' \
    -e 's,^[-+][-+][-+]\s\+\([^ \t]\+\)\s.*,\1,p' \
    | sed -e "$DIREXPR" \
    | uniq)
}
