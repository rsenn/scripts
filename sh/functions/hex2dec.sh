hex2dec() {
 (for N; do
    eval "echo \$((0x${N#0x}))"
  done)
}
