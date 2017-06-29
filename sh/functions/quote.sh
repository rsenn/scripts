quote() {  (unset O
  for A; do case "$A" in
      *\ *) O="${O+$O }'$A'" ;; *)  O="${O+$O }$A" ;;
    esac; done; echo "$O")
  }
