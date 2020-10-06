oct2dec() {
 (for N; do
    echo "ibase=8; base=10; $N" | bc -l
  done)
}
