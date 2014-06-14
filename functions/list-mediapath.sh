list-mediapath()
{
   (while :; do
      case "$1" in
        -*) OPTS="${OPTS+$OPTS
}$1"; shift ;;
          --) shift; break ;;
        *) break ;;
        esac
     done
    for ARG in "$@";
    do
        eval "ls -1 -d \$OPTS -- $MEDIAPATH/\$ARG 2>/dev/null";
    done)
}
