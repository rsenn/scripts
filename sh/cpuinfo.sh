#!/usr/bin/env bash

# This script maps /proc/cpuinfo keywords to USE variable in /etc/make.conf
# /proc/cpuinfo => USE =>    CFLAGS    CONFIGURE_FLAG
# --------------------------------------------------
# mmx           => mmx       -mmmx     --enable-mmx
# mmx2          => mmx2      -mmx2     --enable-mmx2
# mmxext        => mmxext    -mmxext   --enable-mmxext
# sse           => sse       -msse     --enable-sse
# sse2          => sse2      -msse2    --enable-sse2
# ssse3         => sse3      -msse3    --enable-sse3
# sse4a         => sse4a     -msse4a   --enable-sse4a
# 3dnow         => 3dnow     -3dnow    --enable-3dnow
# 3dnowext      => 3dnowext  -3dnowext --enable-3dnowext

# if argument use it otherwise try /proc/cpuinfo
if [ $1 ] ; then
    CPUINFO=$1
else
    CPUINFO=/proc/cpuinfo
fi

if [ ! -r $CPUINFO  ] ; then
    echo File $CPUINFO does not exist or is unreadable.
    exit
fi

if [ -d $CPUINFO  ] ; then
    echo File $CPUINFO is a directory.
    exit
fi

# Determine Target Architecture (GCC -march flag)
MARCH=native;
if ${GREP-grep -a --line-buffered --color=auto} "^model name.* \<Pentium(R) 2\>" $CPUINFO > /dev/null; then
    MARCH="pentium2"; CFLAGS="$CFLAGS -march=$MARCH";
elif ${GREP-grep -a --line-buffered --color=auto} "^model name.* \<Pentium(R) 3\>" $CPUINFO > /dev/null; then
    MARCH="pentium3"; CFLAGS="$CFLAGS -march=$MARCH";
elif ${GREP-grep -a --line-buffered --color=auto} "^model name.* \<Pentium(R) 4\>" $CPUINFO > /dev/null; then
    MARCH="pentium4"; CFLAGS="$CFLAGS -march=$MARCH";
elif ${GREP-grep -a --line-buffered --color=auto} "^model name.* \<AMD Athlon(tm) 64\>" $CPUINFO > /dev/null; then
    MARCH="athlon64"; CFLAGS="$CFLAGS -march=$MARCH";
elif ${GREP-grep -a --line-buffered --color=auto} "^model name.* \<AMD Phenom(tm) II\>" $CPUINFO > /dev/null; then
    MARCH="amdfam10"; CFLAGS="$CFLAGS -march=$MARCH";
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* mmx\>" $CPUINFO > /dev/null; then
    USE="$USE mmx"
    CMFLAGS="$CMFLAGS -mmmx"
    CONF_FLAGS="$CONF_FLAGS --enable-mmx"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* mmx2\>" $CPUINFO > /dev/null; then
    USE="$USE mmx2"
    # TODO: Upcoming version of GCC may add this flag
    # CMFLAGS="$CMFLAGS -mmmx2"
    CONF_FLAGS="$CONF_FLAGS --enable-mmx2"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* mmxext\>" $CPUINFO > /dev/null; then
    USE="$USE mmmxext"
    # TODO: Upcoming version of GCC may add this flag
    # CMFLAGS="$CMFLAGS -mmmxext"
    CONF_FLAGS="$CONF_FLAGS --enable-mmxext"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse\>" $CPUINFO > /dev/null; then
    USE="$USE sse"
    CMFLAGS="$CMFLAGS -mfpmath=sse -msse"
    CONF_FLAGS="$CONF_FLAGS --enable-sse"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse2\>" $CPUINFO > /dev/null; then
    USE="$USE sse2"
    CMFLAGS="$CMFLAGS -msse2"
    CONF_FLAGS="$CONF_FLAGS --enable-sse2"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* ssse3\>" $CPUINFO > /dev/null; then
    USE="$USE sse3"
    CMFLAGS="$CMFLAGS -msse3"
    CONF_FLAGS="$CONF_FLAGS --enable-sse3"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse4\>" $CPUINFO > /dev/null; then
    USE="$USE sse4"
    CMFLAGS="$CMFLAGS -msse4"
    CONF_FLAGS="$CONF_FLAGS --enable-sse4"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse4.1\>" $CPUINFO > /dev/null; then
    USE="$USE sse4.1"
    CMFLAGS="$CMFLAGS -msse4.1"
    CONF_FLAGS="$CONF_FLAGS --enable-sse4.1"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse4.2\>" $CPUINFO > /dev/null; then
    USE="$USE sse4.2"
    CMFLAGS="$CMFLAGS -msse4.2"
    CONF_FLAGS="$CONF_FLAGS --enable-sse4.2"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* abm\>" $CPUINFO > /dev/null; then
    USE="$USE abm"
    CMFLAGS="$CMFLAGS -mabm"
    CONF_FLAGS="$CONF_FLAGS --enable-abm"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse4a\>" $CPUINFO > /dev/null; then
    USE="$USE sse4a"
    CMFLAGS="$CMFLAGS -msse4a"
    CONF_FLAGS="$CONF_FLAGS --enable-sse4a"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* sse5\>" $CPUINFO > /dev/null; then
    USE="$USE sse5"
    CMFLAGS="$CMFLAGS -msse5"
    CONF_FLAGS="$CONF_FLAGS --enable-sse5"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* 3dnow\>" $CPUINFO > /dev/null; then
    USE="$USE 3dnow"
    # CMFLAGS="$CMFLAGS -m3dnow -mfpmath=3dnow"
    CMFLAGS="$CMFLAGS -m3dnow"
    CONF_FLAGS="$CONF_FLAGS --enable-3dnow"
fi

if ${GREP-grep -a --line-buffered --color=auto} "^flags.* 3dnowext\>" $CPUINFO > /dev/null; then
    USE="$USE 3dnowext"
    # TODO: Upcoming version of GCC may add this flag
    # CMFLAGS="$CMFLAGS -m3dnowext"
    CONF_FLAGS="$CONF_FLAGS --enable-3dnowext"
fi

if [ ! $MARCH ]; then
    echo XXX;
    CFLAGS="$CFLAGS $CMFLAGS";
fi

# if argument use it otherwise try /proc/cpuinfo
echo $CPUINFO says
echo - USE: $USE
echo - CFLAGS: $CFLAGS
echo - CONF_FLAGS: $CONF_FLAGS
