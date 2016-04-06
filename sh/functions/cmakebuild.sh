cmakebuild() 
{ 
    builddir=build/cmake
    destdir=${PWD}-linux
    : ${pkgdir=~/Packages}
    : ${python_config=/usr/bin/python2.7-config}
    : ${CXX:=`cmd-path g++`}
    : ${CC:=`cmd-path gcc`}


    cmdexec()  { 
        (IFS=";"
         E="$*"
        while :; do
                case "$1" in 
                    -o) E="exec >>$2; $E"; shift 2 ;; -o*) E="exec >>${1#-o}; $E"; shift ;;
                -w) E="(cd '$2' && $E)"; shift 2 ;;     -w*) E="(cd '${1#-w}' && $E)"; shift ;;
                -m) E="$E 2>&1"; shift ;;
            *) break ;;
            esac
        done
        echo -n "@@ $@" 1>&2 
        eval "$E; R=\$?"
        [ $R = "0" ] && unset R
        echo "${R:+ (exitcode: $R)}" 1>&2
        exit ${R-0})
    }

     find_libpython() {
         ( set -- $(echo $(cmdexec "$python_config" --ldflags --libs )  |sed -n 's,.*-L\([^ ]*\) .*-lpython\([^ ]*\) .*,\1/libpython\2.a,p'; for ext in 'a' 'so.*' ; do ( find $(cmdexec "$python_config" --exec-prefix)/lib*/ -maxdepth 3 -and -not -type d -and -name "libpython*$ext"); done); test -n "$1" -a -f "$1" && echo "$1") \
             2>/dev/null
     }

     python_version=$(cmdexec "$python_config" --cflags|sed 's,.*python\([0-9.]*\) .*,\1,p' -n)

    (
    
    is_interactive || set -e

    trap 'rm -f {cmake,make,install}.log' EXIT
    (: 
     cmdexec -m -o clean.log rm -rf $builddir/ $destdir/
     cmdexec mkdir -p $builddir/)

    (
     
     ( 
    cmdexec -m -w "$builddir" -o cmake.log cmake \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
        -DCONFIG=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_{C,CXX}_FLAGS="-fPIC" \
        -DCMAKE_CXX_COMPILER="$CXX" \
        -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_INSTALL_PREFIX="${prefix:-/usr/local}" \
        -DPYTHON_EXECUTABLE="$(cmdexec "$python_config" --exec-prefix)/bin/python${python_version}" \
        -DPYTHON_INCLUDE_DIR="$(cmdexec "$python_config"  --includes|sed 's,^-I\([^ ]*\) .*,\1,p' -n)" \
        -DPYTHON_LIBRARY="${PYTHON_LIBRARY:-`find_libpython`}" \
    "$@" \
    ../.. )
    ) 


     
        cmdexec -m -o make.log make -C $builddir/      || { ERR=$?; grep '(Stop|failed|error:)' -E  -C3 make.log; exit $?; }
        (
            trap 'cmdexec $SUEXEC rm -rf "$destdir"' EXIT
            cmdexec -m -o install.log $SUEXEC make DESTDIR="$destdir" -C $builddir/ install -i   
            mkdir -p "$pkgdir"
            (cd "$destdir" && cmdexec -m -o pack.log make-archive.sh -q -v -d "$pkgdir" -t txz -9 -r -D)  \
            && notice Created archive "$pkgdir"/"${PWD##*/}"*.txz
        )

    )
}
