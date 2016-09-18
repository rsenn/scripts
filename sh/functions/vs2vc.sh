vs2vc() {
 (NUL=0
  while :; do
    case "$1" in
      -0 | -nul | --nul) : $((NUL++)); shift ;;
      -c | --continue) CONT=true; shift ;;
      -t | --trail*) TRAIL=true; shift ;;
      *) break ;;
    esac
  done
  N=
  while [ $((NUL)) -gt 0 ]; do
    N="${N}0"
    : $((NUL--))
  done
     [ "$TRAIL" = true ] && T=${ARG#*20[0-9][0-9]} || T=

  for ARG; do
   case "$ARG" in
     *2005*) echo 8${N:+.$N}$T ;;
     *2008*) echo 9${N:+.$N}$T ;;
     *2010*) echo 10${N:+.$N}$T ;;
     *2012*) echo 11${N:+.$N}$T ;;
     *2013*) echo 12${N:+.$N}$T ;;
     *2015*) echo 14${N:+.$N}$T ;;
     *) [ "$CONT" = true ] && echo "$ARG" || { echo "No such Visual Studio version: $ARG" 1>&2; exit 1; } ;;
   esac
  done)
}
