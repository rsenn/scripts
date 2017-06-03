conf_mingw () 
{ 
    unset prefix;
    if [ $# -lt 1 ]; then
      set -- $(ls -d -- /usr/bin/*mingw*gcc.exe /mingw*/bin/gcc.exe 2>/dev/null)
    fi
    if [ $# -gt 1 ]; then
      eval "set -- \${$#}"
    fi
    
    for CCPATH; do
    test -d "$CCPATH" && CCPATH=$CCPATH/bin/gcc
        target=$("$CCPATH" -dumpmachine);
        target=${target%''};
        case "$target" in 
            *-mingw*)
                prefix=$( $CC -print-search-dirs|grep libr|removeprefix '*: '|sed 's,=,, ; s,:,\n,g'|xargs realpath 2>/dev/null|sort -f -u |grep 'sys.\?root' |removesuffix /lib)
                : ${prefix:="${CCPATH%%/bin*}"};
		MSYSTEM=MINGW
                break
            ;;
    *-msys*)
		MSYSTEM=MSYS
	    ;;
        esac;
    done;
    if [ -n "$prefix" -a -d "$prefix" ]; then
        [ -n "$host" ] && build="$host";
        host="$target";
        
        sys=$(cygpath -am /|sed 's,.*/,, ; s,-,,g')
        case "$sys" in
          gitsdk*|msys*) builddir="build/$sys" ;;
          *)    builddir="build/$host" ;;
        esac
        pathmunge -f "$prefix/bin";
        CC="${CCPATH##*/}"
        CC=${CC%.exe}
        CXX=${CC/gcc/g++}
        export CC CXX
        unset PKG_CONFIG_PATH;
        init_pkgconfig_path;
    fi
    if [ -e "/usr/bin/pkgconf.exe" ]; then
	    export PKG_CONFIG="/usr/bin/pkgconf"
    fi
    if [ -d "$prefix/lib/pkgconfig" ]; then
	    export PKG_CONFIG_PATH="$prefix/lib/pkgconfig"
    fi
}
