PKG_CONFIG_PATH=$(
  old_IFS="$IFS"; IFS=":"; set -- $PATH; IFS="
";  isin() {  (N="$1"; while [ "$#" -gt 1 ]; do shift; test "$N" = "$1" && exit 0; done; exit 1); }
  P="${*%%/bin*}"; set --; for D in $P; do
    DIR="$D/lib/pkgconfig"; if [ -d "$DIR" ] && ! isin "$DIR" "$@"; then set -- "$@" "$DIR"; fi
  done; IFS=";"; echo "$*"
)
export PKG_CONFIG_PATH

