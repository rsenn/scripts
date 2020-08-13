#!/bin/sh


main() {

for ARG; do
  case "$ARG" in
    *History) ;;
    *) CONFIG="${ARG%%/chrom*}"
      DIR=${ARG#$CONFIG/}
      DIRNAME=${DIR%%/*}

      ARG="$CONFIG/$DIRNAME/Default/History"
      ;;
  esac 
  sqlite3 "$ARG" "SELECT urls.url, visit_time, visit_duration FROM visits INNER JOIN urls on urls.id = visits.url"  |
    sort -t'|' -k2 -n

done
}

main "$@"
