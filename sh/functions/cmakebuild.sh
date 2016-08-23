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
                -w) E="\(cd '$2' && $E\)"; shift 2 ;;     -w*) E="\(cd '${1#-w}' && $E\)"; shift ;;
                -m) E="$E 2>&1"; shift ;;
            *) C="${C:+$C
}$1"; shift ;;
            esac
        done
        [ "$DEBUG" = true ] && echo "EVAL: $E" 1>&2 
        ( 
        trap "$EE;  [ \"\$R\" != 0 ] && echo \"\${R:+\$IFS!! \(exitcode: \$R\)}\" 1>&2 || echo 1>&2; exit \${R:-0}" EXIT
        echo -n "@@" $C 1>&2 
eval "$E; $EE"
exit ${R:-0} 
        ) ; return $?
    }
     find_libpython() {
        : ${python_config:=`cmd-path python-config`}

        if [ -n "$python_config" -a -e "$python_config" ]; then
        : ${python_version:=`$python_config --libs --cflags --includes --ldflags|sed -n '/ython[0-9][0-9.]\+/ { s|.*ython\([0-9][0-9.]\+\).*|\1|; p; q }'`}
        python_exec_prefix=`$python_config --exec-prefix`
        : ${python_executable:=`$python_config --exec-prefix`/bin/python${python_version}}
        : ${python_include_dir:=`$python_config --includes|sed -n 's,^-I\([^ ]*\) .*,\1,p' `}
        python_libs=`echo $($python_config --ldflags --libs)`
        python_library=$( set -x; set -- $(echo $python_libs |sed -n 's,.*-L\([^ ]*\) .*-lpython\([^ ]*\) .*,\1/libpython\2.a,p')

        set -- "$@" `for ext in 'a' 'so.*' ; do find "$python_exec_prefix"/lib*/ -maxdepth 4 -mindepth 1  -and -not -type d -and -name "libpython${python_version}*.$ext"; done`
        while [ ! -e "$1" -a $# -gt 0 ]; do shift; done
        echo "$@"
             )

             require var
             var_s=" " var_dump python_{config,executable,include_dir,library,version}
        else
            errormsg "python-config not found!"
        fi
     }

    : ${pkgdir:=~/Packages}
    : ${CXX:=`cmd-path g++`}
    : ${CC:=`cmd-path gcc`}

    find_libpython

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
                -DPYTHON_EXECUTABLE="$python_executable" \
                -DPYTHON_INCLUDE_DIR="$python_include_dir" \
                -DPYTHON_LIBRARY="$python_library" \
            "$@" \
            ../.. 

            ) || return $?
        cmdexec -m -o make.log make -C $builddir/      || { ERR=$?; ${GREP-grep
-a
--line-buffered
--color=auto} '(Stop|failed|error:)' -E  -C3 make.log; return $?; }
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
