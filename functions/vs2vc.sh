vs2vc() {
 (NUL=0
  while :; do
    case "$1" in
      -0 | -nul | --nul) : $((NUL++)); shift ;;
      *) break ;;
    esac
  done
  N=
  while [ $((NUL)) -gt 0 ]; do
    N="${N}0"
    : $((NUL--))
  done
  for ARG; do
   case "$ARG" in
     2005) echo 8${N:+.$N} ;; 
     2008) echo 9${N:+.$N} ;; 
     2010) echo 10${N:+.$N} ;; 
     2012) echo 11${N:+.$N} ;; 
     2013) echo 12${N:+.$N} ;; 
     2015) echo 14${N:+.$N} ;; 
     *) echo "No such Visual Studio version: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}