MACPORTS_ROOT=/opt/local

set-macports() {
  PATH=$MACPORTS_ROOT/bin:$MACPORTS_ROOT/libexec/gnubin:$(IFS=":"; O=; for D in $PATH; do 
    case "$D" in
      */local/* |*/local) continue ;;
      */gnubin) continue ;;
      *) O="${O:+$O:}$D" ;;
    esac
done
echo "$O")
}

set-macports
#PATH="/usr/local/bin:/opt/local/bin:$PATH"
#PATH="/opt/local/libexec/gnubin:$PATH"
