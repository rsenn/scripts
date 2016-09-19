hex2bin() {
 (
  for N ; do
    
    echo "binary scan [binary format H* \"${N#0x}\"] B* b
puts \$b"
  done) | tclsh| addprefix "${P-0b}"
}
