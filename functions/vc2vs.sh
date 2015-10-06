vc2vs() {
 (while :; do
    case "$1" in
      -c | --continue) CONT=true; shift ;;
      -t | --trail*) TRAIL=true; shift ;;
      *) break ;;
    esac
  done
  for ARG; do
   ARG=${ARG#*msvc}
   ARG=${ARG#-}
   ARG=${ARG##*"Visual Studio "}
   ARG=${ARG%%[/\\]*}
   ARG=${ARG#vc}
   NUM=${ARG%%[!0-9.]*}
   [ "$TRAIL" = true ] && T=${ARG#$NUM} || T=
   case "${NUM}" in
     8 | 8.0 | 8.00) echo 2005$T ;;
     9 | 9.0 | 9.00) echo 2008$T ;;
     10 | 10.0 | 10.00) echo 2010$T ;;
     11 | 11.0 | 11.00) echo 2012$T ;;
     12 | 12.0 | 12.00) echo 2013$T ;;
     14 | 14.0 | 14.00) echo 2015$T ;;
     *) [ "$CONT" = true ] && echo "$ARG" || { echo "No such Visual Studio version: $ARG" 1>&2; exit 1; } ;;
   esac
  done)
}
