: ${arm_linux_gnueabihf_CFLAGS="-march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4"}
: ${arm_linux_gnueabihf_CXXFLAGS=$arm_linux_gnueabihf_CFLAGS}

arm-linux-gnueabihf-make() { 
  (FNAME=${FUNCNAME[0]}
		CHOST=${FNAME%-make};
declare \
	CC="$CHOST-gcc${SYSROOT:+ --sysroot="$SYSROOT"}"  \
CXX="$CHOST-g++${SYSROOT:+ --sysroot="$SYSROOT"}" 

		for VAR in CCFLAGS CXXFLAGS ; do 
			eval "${VAR%FLAGS}=\"\$${VAR%FLAGS} \$${CHOST//-/_}_$VAR\""
		done

		set -- make CC="$CC" {CXX,CCLD,LINK}="$CXX" "$@" 

		if [ -n "$SYSROOT" -a -d "$SYSROOT" ]; then
			export PKG_CONFIG_PATH="$(ls -d $SYSROOT/{usr/,}{lib/,share/}{,*/}pkgconfig 2>/dev/null |implode :)"
			export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
    fi
		[ "$DEBUG" = true ] && set -x

		"$@")
}
