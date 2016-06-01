#!/bin/sh
NL="
"

IFS="
"
MYDIR=`dirname "$0"`

cd "$MYDIR" 

ABSDIR=`cd "$MYDIR" && pwd`

[ $# -le 0 ] && SUBDIRS=`ls -d */ | ${SED-sed} "s|/\$||"` || SUBDIRS="$*"

for SUBDIR in $SUBDIRS; do

  SUBDIR=${SUBDIR%%/VC*}
  if [ -d "$SUBDIR" ]; then
    SUBDIR=`cd "$SUBDIR" && echo "${PWD#$ABSDIR/}"`
  fi
  SUBDIRNAME=${SUBDIR##*/}
  #echo "SUBDIRNAME=$SUBDIRNAME" 1>&2
  case "$SUBDIRNAME" in
    *2015* | *\ 14.0) MSVC_VERSION=14 VS_VERSION=2015 ;;
    *2013* | *\ 12.0) MSVC_VERSION=12 VS_VERSION=2013 ;;
    *2012* | *\ 11.0) MSVC_VERSION=11 VS_VERSION=2012 ;;
    *2010* | *\ 10.0) MSVC_VERSION=10 VS_VERSION=2010 ;;
    *2008* | *\ 9.0) MSVC_VERSION=9 VS_VERSION=2008 ;;
    *) MSVC_VERSION= ;;
  esac
  echo "MSVC version: $MSVC_VERSION" 1>&2

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

  LIBDIRS=`find "$SUBDIR" -maxdepth 1 -mindepth 1 | ${SED-sed} "s|.*/||"`

  LIBNAMES=`echo "$LIBDIRS" | ${SED-sed} "s|[-_][0-9][^/]*\$||" | uniq`

  USELIBS=`
    for NAME in $LIBNAMES; do
      echo "$LIBDIRS" | 
      ${GREP-grep
-a
--line-buffered
--color=auto} "^${NAME}[-_][0-9]" |
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

    L=`ls -d "$P/$SUBDIR/$LIBSUBDIR"/*lib*/*.{a,lib} 2>/dev/null | ${SED-sed} "s|/[^/]*\$||" | uniq`
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

  ) | { O="set-msvc${VS_VERSION}-vars.cmd"; echo "Writing $O ..." 1>&2; ${SED-sed} "s|\$|\\r|" >"$O"; }

  #echo "$LIBNAMES"



  #"(" -iname include -or -iname lib ")" |${SED-sed} "s|^|$P/|"
done
