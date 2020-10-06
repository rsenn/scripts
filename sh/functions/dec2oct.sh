dec2oct() {
 (for N; do
    echo "ibase=10; base=8; $N" | bc -l
  done)
}
