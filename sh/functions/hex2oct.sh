hex2oct() {
 (for NUM; do
   eval "dec2oct \$((0x${NUM#0x}))"
  done)
}
