dec2hex() { 
  (for N; do 
   ([ "$N" -le 255 ] && : ${DIGITS=2}
    printf "${D2XPFX}%0${DIGITS-8}x\n" "$N")
   done)
}
