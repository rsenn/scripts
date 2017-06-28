dec-to-hex() { 
  (for N; do printf "${D2XPFX}%08x\n" "$N"; done)
}
