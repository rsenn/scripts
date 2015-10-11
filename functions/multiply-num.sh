multiply-num() {
 (for ARG; do
    case "$ARG" in
      *[0-9].* | *.[0-9]*) CMD='$(bc -l <<\EOF
'$ARG'
EOF
)'  ;;
      *) CMD='$(( '$ARG' ))' ;;
    esac
    eval "N=$CMD"
    case "$N" in
      .*) N="0$N" ;;
      *.*0) while [ "$N" != "${N%0}" ]; do N=${N%0}; done ;;
    esac
    echo "${N%.}"
  done)
}
