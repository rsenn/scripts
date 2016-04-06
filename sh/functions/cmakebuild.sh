cmakebuild() 
{ 
    builddir=build/cmake
    destdir=${PWD}-linux
    : ${pkgdir=~/Packages}
    : ${python_config=/usr/bin/python2.7-config}
     find_libpython() {
         ( set -- $(echo $($python_config --ldflags --libs )  |sed -n 's,.*-L\([^ ]*\) .*-lpython\([^ ]*\) .*,\1/libpython\2.a,p'; for ext in 'a' 'so.*' ; do ( find $($python_config --exec-prefix)/lib*/ -maxdepth 3 -and -not -type d -and -name "libpython*$ext"); done); test -n "$1" -a -f "$1" && echo "$1")
     }
    (
    
    is_interactive || set -e

    trap 'rm -f {cmake,make,install}.log' EXIT
    (: set -x
     rm -rf $builddir/ $destdir/
     mkdir -p $builddir/)

    (
     
     ( set -x;
     cd "$builddir" &&
    cmake \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
        -DCONFIG=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_{C,CXX}_FLAGS="-fPIC" \
        -DCMAKE_CXX_COMPILER="${CXX:-`which g++`}" \
        -DCMAKE_C_COMPILER="${CC:-`which gcc`}" \
        -DCMAKE_INSTALL_PREFIX="$($python_config --exec-prefix)" \
        -DPYTHON_EXECUTABLE="$($python_config --exec-prefix)/bin/python2" \
        -DPYTHON_INCLUDE_DIR="$($python_config  --includes|sed 's,^-I\([^ ]*\) .*,\1,p' -n)" \
        -DPYTHON_LIBRARY="${PYTHON_LIBRARY:-`find_libpython`}" \
    "$@" \
    ../.. 2>&1)
    ) >cmake.log


    ( set -x
    make -C $builddir/ 2>&1 )     >make.log || { ERR=$?; grep '(Stop|failed|error:)' -E  -C3 make.log; exit $?; }
    (
        trap '${SUEXEC:-command} rm -rf "$destdir"' EXIT
        (set -x; ${SUEXEC:-command} make DESTDIR="$destdir" -C $builddir/ install -i 2>&1 ) \
            >install.log
        mkdir -p "$pkgdir"
        (set -x; cd "$destdir" && make-archive.sh -q -v -d "$pkgdir" -t txz -9 -r -D)  \
        && notice Created archive "$pkgdir"/"${PWD##*/}"*.txz
    )
    set +e

    )
}
