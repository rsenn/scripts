bit2arch() {
 (for ARG; do
   case "$ARG" in
     32 | 32[!0-9]* | *[!0-9]32 | *[!0-9]32[!0-9]*) echo x86 ;;
     64 | 64[!0-9]* | *[!0-9]64 | *[!0-9]64[!0-9]*) echo x64 ;;
     *) echo "No such bit count: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}
