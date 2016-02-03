suffix-num() {
 (for N; do
    case "$N" in
      [0-9]*P) N=$(multiply-num "${N%P} * 1099511627776") ;;
      [0-9]*G) N=$(multiply-num "${N%G} * 1073741824") ;;
      [0-9]*M) N=$(multiply-num "${N%M} * 1048576") ;;
      [0-9]*[Kk]) N=$(multiply-num "${N%[Kk]} * 1024") ;;
    esac
    echo ${N%.*}
  done)
}
