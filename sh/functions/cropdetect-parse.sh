cropdetect-parse() {

 (while read -r LINE; do
    (IFS=" "; set -- ; for DATA in $LINE; do
       case "$DATA" in
  *=*) set -- "$@" $DATA ;;
   *:[0-9]*) set -- "$@" ${DATA%%:*}=${DATA#*:} ;;
esac
done
echo "$@" )

  done)
}
