str_quote() { 
 (unset O; SQ="'"; DQ='"'; BS="\\"
  for A; do case "$A" in
    *\ * | *[\|\(\)]*) O="${O+$O }'${A//"$SQ"/"$SQ$BS$SQ$SQ"}'" ;;
    *)  A=${A//"$SQ"/"$BS$SQ"}; A=${A//"$DQ"/"$BS$DQ"}; O="${O+$O } $A" ;;

  esac; done; echo "$O")
}
