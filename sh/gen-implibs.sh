#!/bin/sh
NL="
"

if [ -d "$1" ]; then
  DIR="$1"
else
  DIR=`dirname "$0"`
fi

cd "$DIR"

if type pexports >/dev/null 2>/dev/null; then
  PEXPORTS="pexports"
elif type impgen >/dev/null 2>/dev/null; then
  PEXPORTS="impgen"
fi

if [ -f dlltool.exe ]; then
  DLLTOOL="./dlltool.exe"
fi

# make_implib <dll> <out-implib>
make_implib()
{
  DLL="$1" DEF="${1%.dll}.def" LIB="$2"
  
  ${PEXPORTS} "$DLL" >"$DEF"
  
  ${DLLTOOL:-dlltool} --output-lib "$LIB" --dllname "${DLL##*/}" --input-def "$DEF"
}

for DLL in *.dll; do
 (LIBNAME=${DLL%.dll}
  
  NAME=${LIBNAME#lib}
  
  ANAME=`echo "$NAME" | ${SED-sed} 's,-[0-9][_0-9]*$,,'`
  #ANAME=`echo "$NAME" | ${SED-sed} 's,[0-9]\+$,,'`
  
  IMPLIB=`ls -d ../lib/lib${ANAME}*.dll.a 2>/dev/null | ${GREP-grep
-a
--line-buffered
--color=auto} "/lib/lib${ANAME}[-_0-9]*\.dll.a\$"`
  MSIMPLIB=`ls -d ../lib/${ANAME}*.lib 2>/dev/null | ${GREP-grep
-a
--line-buffered
--color=auto} "/lib/${ANAME}[-_0-9]*\.lib\$"`
  
  if [ -z "$IMPLIB" ]; then
    echo "No import library for $DLL" 1>&2
    make_implib "$DLL" ../lib/lib${ANAME}.dll.a
  fi
  
  
  if [ "$LIBNAME" != "$NAME" -a -z "$MSIMPLIB" ]; then
    echo "No MS import library for $DLL" 1>&2
    make_implib "$DLL" ../lib/${ANAME}.lib
  fi
  
  set -- $DLL $IMPLIB $MSIMPLIB
  
  echo $*)
done
