arch2bit() {
 (for ARG; do
   case "$ARG" in
     *x64* | *x86?64*) echo 64 ;;
     *x86* | *i[3-6]86*) echo 32 ;;
     *) echo "No such arch: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}
