oct2hex() {
 (for N; do
    eval "dec2hex \$((0${N}))"
  done)
}
