build-arm-linux () 
{ 
    ( for ARG in "$@";
    do
        ( cd "$ARG";
        set -- *.jucer;
        test -n "$1" -a -f "$1" && ( set -x;
        Introjucer --add-exporter "Linux Makefile" "$1" || Projucer --add-exporter "Linux Makefile" "$1";
        Introjucer --resave "$1" || Projucer --resave "$1" );
        set -x;
        PKG_CONFIG_PATH=$(cygpath -a m:/opt/debian-jessie-a20/usr/lib/pkgconfig) make -C Builds/Linux* CONFIG=Release SYSROOT=m:/opt/debian-jessie-a20 CROSS_COMPILE="arm-linux-gnueabihf-" CXX="g++ --sysroot=\$(SYSROOT)  -I\$(SYSROOT)/usr/include -march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4" ) || { 
            r=$?;
            echo "Failed $ARG" 1>&2;
            exit $r
        };
    done )
}
