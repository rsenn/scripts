dec2bin() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$\(\($N\)\)" ;;
    esac
    echo "obase=2;$N" | bc -l
  done | addprefix "${P-0b}")
}
