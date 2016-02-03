hex2dec() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$(($N))" ;;
    esac
    echo "obase=10;$N" | bc -l
  done | addprefix "${P-}")
}
