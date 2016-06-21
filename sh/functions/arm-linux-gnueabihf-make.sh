arm-linux-gnueabihf-make() { 
    ( CHOST=${0%-make};

		if [ -n "$SYSROOT" -a -d "$SYSROOT" ]; then
			export PKG_CONFIG_PATH="$(ls -d $SYSROOT/{usr/,}{lib/,share/}{,*/}pkgconfig 2>/dev/null |implode :)"
			export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
    fi
    make CC="$CHOST-gcc${SYSROOT:+ --sysroot="$SYSROOT"}" CXX="$CHOST-g++${SYSROOT:+ --sysroot="$SYSROOT"}" "$@" )
}
