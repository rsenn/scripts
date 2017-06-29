
quote() {  (unset O; SQ="'"; DQ='"'; BS="\\"
  for A; do case "$A" in
      *\ *) O="${O+$O }'${A//"$SQ"/"$SQ$BS$SQ$SQ"}'" ;;
      *)  O="${O+$O }${A//"$SQ"/"$BS$SQ"}" ;;

    esac; done; echo "$O")
  }
