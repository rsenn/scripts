if [ "${PKG_CONFIG_PATH+set}" != set ]; then
  old_IFS=$IFS IFS=:; set -- $PATH; IFS=";
";isin() { N=$1; while [ "$#" -gt 1 ]; do shift; [ "$N" = "$1" ] && return 0; done; return 1
  }; P="${*%%/bin*}"; set --; for D in $P; do D=$D/lib/pkgconfig; if [ -d "$D" ]; then
	 type cygpath 2>/dev/null >/dev/null && IFS=: && D=`cygpath -a "$D"`
	 ! isin "$D" "$@" && set -- "$@" "$D"
  fi; done; PKG_CONFIG_PATH=$*; IFS=$old_IFS
fi

export PKG_CONFIG_PATH

