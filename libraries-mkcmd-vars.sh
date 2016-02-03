#!/bin/sh
IFS="
"
FS=/
BS=\\
. bash_functions.sh
MYNAME=`basename "$0" .sh`
MYDIR=`dirname "$0"`
main() {
  cd "$MYDIR"
  for TARGET in vs{2008,2010,2012,2013,2015}-{x86,amd64} {x86_64,i686}-w64-mingw32; do
    OUTPUT=$TARGET-vars.cmd
    (
    OUTPUT=`cygpath -w "$PWD/$OUTPUT"`
    CALLARG=${TARGET#*-}
    echo "TARGET=$TARGET" 1>&2
    case "$TARGET" in 
      vs*) VARS="$PROGRAMFILES (x86)\\Microsoft Visual Studio $(vs2vc -0 "$TARGET")\\VC\\vcvarsall.bat"  ;;
    *mingw*) 
      TARGETDIR=$(realpath $PWD/mingw-w64/$TARGET) 
      MINGWDIR=$(realpath "$TARGETDIR/..")
      VARS=$(realpath "$MINGWDIR/mingw-w64.bat"| xargs cygpath -m | ${SED-sed} 's,/,\\,g')
      CALLARG= 
      ;;
   esac
    cd "$MYDIR"
    (echo "@echo off
echo Loading variables for $TARGET
echo.
"
    case "$TARGET" in
      vs*) ;;
      *) 
        set -- $(realpath $PWD/*/${TARGET/amd64/*64}*/bin)
        grep -iE "(mingw-w64)" <<<"$*" | xargs cygpath -w |implode ';'|addprefix 'set PATH=%PATH%;'
      ;;
    esac
    realpath $PWD/*/${TARGET/amd64/*64}*/include|xargs cygpath -w |implode ';'|addprefix 'set INCLUDE=%INCLUDE%;'
    realpath $PWD/*/${TARGET/amd64/*64}*/lib |xargs cygpath -w |implode ';'|addprefix 'set LIB=%LIB%;'
    case "$TARGET" in
      *mingw*)
        builddir=build/$(get-mingw-properties TARGET -- "$TARGETDIR")
        echo
        ls -d $PWD/*/${TARGET/amd64/*64}*/include|xargs cygpath -w |addprefix '-I"' |addsuffix '"' |implode " " |addprefix 'set INCLUDES='
        for v in CPPFLAGS CFLAGS CXXFLAGS; do echo "rem set ${v}=%${v}% %INCLUDES%"; done
        echo
        ls -d $PWD/*/${TARGET/amd64/*64}*/lib|xargs cygpath -w|addprefix '-L"' |addsuffix '"' |implode " " |addprefix 'rem set LIBS=' 
        for v in LDFLAGS; do echo "rem set ${v}=%${v}% %LIBS%"; done
      ;;
    esac
    : ${builddir=build/$TARGET}
    if [ -n "$builddir" ]; then
      echo "
set builddir=${builddir//$FS/$BS}
"
    fi
    echo "\"$VARS\"${CALLARG:+ $CALLARG}"
    ) |unix2dos |(set -x; tee "$OUTPUT" >/dev/null)
   )
  done
}
implode () 
{ 
    ( unset DATA SEPARATOR;
    SEPARATOR="$1";
    shift;
    CMD='DATA="${DATA+$DATA$SEPARATOR}$ITEM"';
    if [ $# -gt 0 ]; then
        CMD="for ITEM; do $CMD; done";
    else
        CMD="while read -r ITEM; do $CMD; done";
    fi;
    eval "$CMD";
    echo "$DATA" )
}
addsuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "$LINE$SUFFIX"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}
addprefix () 
{ 
    ( PREFIX=$1;
    shift;
    CMD='echo "$PREFIX$LINE"';
    [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done";
    eval "$CMD" )
}
vs2vc() {
 (NUL=0
  while :; do
    case "$1" in
      -0 | -nul | --nul) : $((NUL++)); shift ;;
      *) break ;;
    esac
  done
  N=
  while [ $((NUL)) -gt 0 ]; do
    N="${N}0"
    : $((NUL--))
  done
  for ARG; do
   case "$ARG" in
     *2005*) echo 8${N:+.$N} ;; 
     *2008*) echo 9${N:+.$N} ;; 
     *2010*) echo 10${N:+.$N} ;; 
     *2012*) echo 11${N:+.$N} ;; 
     *2013*) echo 12${N:+.$N} ;; 
     *2015*) echo 14${N:+.$N} ;; 
     *) echo "No such Visual Studio version: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}
var_dump() { 
 (for N; do
    N=${N%%=*}
    O=${O:+$O${var_s-${IFS%${IFS#?}}}}$N=`eval 'str_quote "${'$N'}"'`
  done
  echo "$O")
}
str_quote () 
{ 
    case "$1" in 
        *["$cr$lf$ht$vt"]*)
            echo "\$'`str_escape "$1"`'"
        ;;
        *"$squote"*)
            echo "\"`str_escape "$1"`\""
        ;;
        *)
            echo "'$1'"
        ;;
    esac
}
str_escape () 
{ 
    local s=$1;
    case $s in 
        *[$cr$lf$ht$vt'€']*)
            s=${s//'\'/'\\'};
            s=${s//''/'\r'};
            s=${s//'
'/'\n'};
            s=${s//'  '/'\t'};
            s=${s//''/'\v'};
            s=${s//\'/'\047'};
            s=${s//''/'\001'};
            s=${s//'€'/'\200'}
        ;;
        *$sq*)
            s=${s//"\\"/'\\'};
            s=${s//"\""/'\"'};
            s=${s//"\$"/'\$'};
            s=${s//"\`"/'\`'}
        ;;
    esac;
    echo "$s"
}
str_escape () 
{ 
    local s=$1;
    case $s in 
        *[$cr$lf$ht$vt'€']*)
            s=${s//'\'/'\\'};
            s=${s//''/'\r'};
            s=${s//'
'/'\n'};
            s=${s//'  '/'\t'};
            s=${s//''/'\v'};
            s=${s//\'/'\047'};
            s=${s//''/'\001'};
            s=${s//'€'/'\200'}
        ;;
        *$sq*)
            s=${s//"\\"/'\\'};
            s=${s//"\""/'\"'};
            s=${s//"\$"/'\$'};
            s=${s//"\`"/'\`'}
        ;;
    esac;
    echo "$s"
}
str_escape () 
{ 
    local s=$1;
    case $s in 
        *[$cr$lf$ht$vt'€']*)
            s=${s//'\'/'\\'};
            s=${s//''/'\r'};
            s=${s//'
'/'\n'};
            s=${s//'  '/'\t'};
            s=${s//''/'\v'};
            s=${s//\'/'\047'};
            s=${s//''/'\001'};
            s=${s//'€'/'\200'}
        ;;
        *$sq*)
            s=${s//"\\"/'\\'};
            s=${s//"\""/'\"'};
            s=${s//"\$"/'\$'};
            s=${s//"\`"/'\`'}
        ;;
    esac;
    echo "$s"
}
main "$@"
