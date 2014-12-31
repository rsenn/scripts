#!/bin/sh

MYDIR=`dirname "$0"`

cd "$MYDIR" 

ABSDIR=`cd "$MYDIR" && pwd`

[ $# -le 0 ] && SUBDIRS=`ls -d */ | sed "s|/\$||"` || SUBDIRS="$*"

for SUBDIR in $SUBDIRS; do

  if [ -d "$SUBDIR" ]; then
    SUBDIR=`cd "$SUBDIR" && echo "${PWD#$ABSDIR/}"`
  fi

  case "$SUBDIR" in
    *2015*) MSVC_VERSION=14 ;;
    *2013*) MSVC_VERSION=12 ;;
    *2012*) MSVC_VERSION=11 ;;
    *2010*) MSVC_VERSION=10 ;;
    *) MSVC_VERSION= ;;
  esac

  case "$SUBDIR" in
    *x64* | *x86*64* | *amd64*) PLATFORM_DEFAULT=amd64 ;;
    *) PLATFORM_DEFAULT=x86 ;;
  esac

  if [ -n "$MSVC_VERSION" ]; then
    MSVC_DIR=`ls -d "$SYSTEMDRIVE"/Prog*/*Visual*Studio*${MSVC_VERSION}*/VC`
  else
    MSVC_DIR=
  fi
  MSVC_VARSALL="$MSVC_DIR/vcvarsall.bat"
  if [ ! -f  "$MSVC_VARSALL" ]; then
    echo "No $MSVC_VARSALL" 1>&2
  fi

  P=`cygpath -m "$PWD"`

  LIBDIRS=`find "$SUBDIR" -maxdepth 1 -mindepth 1 | sed "s|.*/||"`

  LIBNAMES=`echo "$LIBDIRS" | sed "s|[-_][0-9][^/]*\$||" | uniq`

  USELIBS=`
    for NAME in $LIBNAMES; do
      echo "$LIBDIRS" | 
      grep "^${NAME}[-_][0-9]" |
      sort -V |
      tail -n1
    done
  `

  ADD_INCLUDE=
  S=";"
  IFS="
  ${S}"

  push() {
    eval "shift;$1=\${$1:+\$$1\$S}\${*}"
  }

  for LIBSUBDIR in $USELIBS; do
    I="$P/$SUBDIR/$LIBSUBDIR/include"

    [ -d "$I" ] || I="$P/$SUBDIR/$LIBSUBDIR"

    push ADD_INCLUDE $I

    L=`ls -d "$P/$SUBDIR/$LIBSUBDIR"/*lib*/*.{a,lib} 2>/dev/null | sed "s|/[^/]*\$||" | uniq`
    push ADD_LIB $L
  done

  (
cat <<EOF
@echo off

call "${MSVC_VARSALL}" %1

set INCLUDE=%INCLUDE%;${ADD_INCLUDE}
set LIB=%LIB%;${ADD_LIB}

if [%1] == [] (
  set PLATFORM=$PLATFORM_DEFAULT
) else (
  set PLATFORM=%1
)

echo Variables are now set up for Visual Studio $MSVC_VERSION (%PLATFORM%)

EOF

  ) | { O="set-$SUBDIR-vars.cmd"; echo "Writing $O ..." 1>&2; sed "s|\$|\\r|" >"set-$SUBDIR-vars.cmd"; }

  #echo "$LIBNAMES"



  #"(" -iname include -or -iname lib ")" |sed "s|^|$P/|"
done
