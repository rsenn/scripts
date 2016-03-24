filter-filesize() {
  (OPS=
  IFS="
"; getnum() {
    N=$1
    case "$N" in
      *[Kk]) N=$(( ${N%[Kk]} * 1024 )) ;;
      *G) N=$(( ${N%G} * 1024 * 1048576)) ;;
      *T) N=$(( ${N%T} * 1048576 * 1048576)) ;;
      *M) N=$(( ${N%M} * 1048576 )) ;;
    esac
    echo "$N"
  }
  while :; do
    case "$1" in
      -gt | -ge | -lt | -le) OPS="${OPS:+$OPS$IFS}\$FILESIZE${IFS}$1${IFS}\$(($(getnum "$2")))"; shift 2 ;;
      -a | -o) OPS="${OPS:+$OPS$IFS}${1}"; shift ;;
      *) break ;;
    esac
  done
  xargs ls -l -d -n --time-style="+%s" -- | {
   set -- $OPS
   IFS=" "
   CMD="test $*"
   while read -r MODE N USERID GROUPID FILESIZE DATETIME PATH; do
     #echo "$FILESIZE" 1>&2
      eval "if $CMD; then echo \"\$PATH\"; fi"

  done; }
  )
}
