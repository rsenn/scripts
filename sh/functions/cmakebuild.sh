cmakebuild() 
{ 
    builddir=build/cmake
    destdir=${PWD}-linux

   unset X_RM_O
    cmdexec()  { 
        IFS="
"
        R= C= E="set -- \$C; \"\$@\"" EE=': ${R:=$?}; [ "$R" = "0" ] && unset R'
        o() {  X_RM_O="${X_RM_O:+$X_RM_O$IFS}$1"; E="exec >>'$1'; $E"; }
        while [ $# -gt 0 ]; do
                case "$1" in 
                    -o) o "$2"; shift 2 ;; -o*) o "${1#-o}"; shift ;;
                -w) E="(cd '$2' && $E)"; shift 2 ;;     -w*) E="(cd '${1#-w}' && $E)"; shift ;;
                -m) E="$E 2>&1"; shift ;;
            *) C="${C:+$C
}$1"; shift ;;
            esac
        done
        [ "$DEBUG" = true ] && echo "EVAL: $E" 1>&2 
        (trap "$EE;  [ \"\$R\" != 0 ] && echo \"\${R:+\$IFS!! (exitcode: \$R)}\" 1>&2 || echo 1>&2; exit \${R:-0}" EXIT
        echo -n "@@" $C 1>&2 
eval "$E; $EE"
exit ${R:-0}) ; return $?
    }
     find_libpython() {
         ( set -- $(echo $(cmdexec "$python_config" --ldflags --libs )  |sed -n 's,.*-L\([^ ]*\) .*-lpython\([^ ]*\) .*,\1/libpython\2.a,p'; for ext in 'a' 'so.*' ; do ( find $(cmdexec "$python_config" --exec-prefix)/lib*/ -maxdepth 3 -and -not -type d -and -name "libpython*$ext"); done); test -n "$1" -a -f "$1" && echo "$1") \
             2>/dev/null
     }

    : ${pkgdir=~/Packages}
    : ${python_config=/usr/bin/python2.7-config}
    : ${python_version=$(cmdexec "$python_config" --cflags|sed 's,.*python\([0-9.]*\) .*,\1,p' -n)}
    : ${CXX:=`cmd-path g++`}
    : ${CC:=`cmd-path gcc`}

    is_interactive || set -e

  (set -e
     #trap 'rm -vf -- $X_RM_O {cmake,make,install}.log' EXIT
       cmdexec -m -o clean.log rm -rf "$builddir" "$destdir"
       cmdexec mkdir -p "$builddir"
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
            ../.. 

            ) || return $?
        cmdexec -m -o make.log make -C $builddir/      || { ERR=$?; grep '(Stop|failed|error:)' -E  -C3 make.log; return $?; }
       (set -e
            trap 'cmdexec $SUEXEC rm -rf -- "$destdir"' EXIT
            cmdexec -m -o install.log $SUEXEC make DESTDIR="$destdir" -C $builddir/ install -i   
            mkdir -p "$pkgdir"
            cmdexec -w "$destdir" -m -o pack.log make-archive.sh -q -v -d "$pkgdir" -t txz -9 -r -D && notice Created archive "$pkgdir"/"${PWD##*/}"*.txz
            ) || return $?
        R=$? 
        [ "$R" = 0 ] && notice "cmakebuild done!"
       #rm -vf -- $X_RM_O {cmake,make,install}.log
}
