cmdprint() { 
 (unset O;
  while :; do
    case "$1" in
      -*) pushv OPTS "$1"; shift ;;
      *) break ;;
    esac
  done
  for A; do
    case "$A" in 
      *\ *) O=${O+$O }'$A' ;;
      *) O=${O+$O }$A ;;
    esac
  done
  echo $OPTS "$O")
}
