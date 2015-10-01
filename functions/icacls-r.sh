icacls-r() { 
 (for ARG; do
   (set -x
    icacls "$(cygpath -w "$ARG")" /Q /C /T /RESET)
  done)
}
