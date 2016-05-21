list-mingw-toolchains() {
  require var
 ansicolor() {
   (IFS=";"; echo -n -e "\033[${*}m")
 }
 NL="
"
  TS=$'\t'
  BS="\\"
  FS="/"
  CR=$'\r'
  evalcmd() {
    CMD=$1
    [ "$DEBUG" = true ] && {
      OUT="+ ${ansi_red}${2:-CMD}${ansi_cyan}: ${ansi_none}$CMD"
      OUT="${OUT//\\[!-0-9A-Za-z_.]/}"
            echo -e "$OUT" 1>&2
      case "$CMD" in
      [A-Z_]*=*)
      VN=${CMD%%[!A-Za-z0-9_]*} ;       eval 'echo "'$VN'=\"${'$VN'//$BS/$BS$BS}\""'
      ;;
      esac
    }
    eval "$CMD"
  }
  vdump() {
   (
    echo -n "-"
   CMD=
   LINESPACE=$'\n>'
     for __VN; do
      SQ="\\\"" TQ="\\\""
      SEP=" "
      case "$__VN" in
        [!A-Za-z_]*)
        CMD="${CMD:+$CMD\\n}"; continue ;;
      esac
      eval "__VV=\${$__VN}"
      case "$__VV" in
        *[!0-9A-Za-z_\ $NL]*) ;;
        *)
        SEP=' ' ;;
      esac
      case "$__VV" in
        [A-Z]*) SQ='(' TQ=')'; SEP=' ' ;;
        /*) SQ='(\\n  ' TQ='\n)'; SEP='\\n  ' ;;
        -* | *" -"* | *"$NL-"*) SQ=' ' TQ='   '; SEP='\\n\\t' ;;
        *"\\"*) SQ=\' TQ=\'; SEP=';' ;;
      esac
      CMD="${CMD:+$CMD${LINESPACE:-\\\\n}}${ansi_none}${ansi_yellow}$__VN${ansi_cyan}=${SQ:-\"}\${$__VN${SEP:+//\$NL/$SEP}}${TQ:-\"}${ansi_none}"
    done
    CMD=${CMD//"\\["/""}; CMD=${CMD//"\\]"/""}
    CMD=${CMD//"$NL"/"\\n"}
    DEBUG= evalcmd "echo -e \"$CMD\" 1>&2" DUMP)
  }
 (unset ROOTS
  while :; do
    case "$1" in
   -C | --nocolor) NOCOLOR=true; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      -r | -rootdir | --rootdir) shift; while [ "$1" = "${1#-}" ]; do  IFS=" " pushv ROOTS "${1%[/\\]}/*/mingw??/bin/gcc"; shift; done ;;
      -r=* | -rootdir=* | --rootir=*) V=${1#*=}; IFS=" " pushv ROOTS "${V%/}/*/mingw??/bin/gcc"; shift ;;
      -r) V=${1#-?}; IFS=" " pushv ROOTS "${V%/}/*/mingw??/bin/gcc"; shift ;;
      -c | -cc | --cc | --compiler) IFS=$nl pushv O CC ; shift ;;
      -b | -basedir | --basedir) IFS=$nl pushv O BASEDIR ; shift ;;
      -d | -hostdir | --hostdir) IFS=$nl pushv O HOSTDIR ; shift ;;
      -v | -vars | --vars) IFS=$nl pushv O VARS; shift ;;
      -p | -pathconv | --pathconv) PATHCONV="$2"; shift 2 ;; -p=* | -pathconv=* | --pathconv=*) IFS="$nl "; PATHCONV="${1#-*=}"
      PATHCONV=${PATHCONV//" "/"${NL}"}; shift ;;
      -t | -tool | --tool) IFS=$nl pushv TOOL "$2"; IFS=$nl pushv O TOOL_${2}; shift 2 ;; -t=* | -tool=* | --tool=*) IFS=$nl pushv TOOL "${1#*=}"
      IFS=$nl pushv O TOOL_${1#*=}; shift 1 ;;
      --defs | -defs) IFS=$nl pushv O DEFS; shift ;;
      --cflags | -cflags) IFS=$nl pushv O CFLAGS; shift ;;
      --cppflags | -cppflags) IFS=$nl pushv O CPPFLAGS; shift ;;
      --cxxflags | -cxxflags) IFS=$nl pushv O CXXFLAGS; shift ;;
      --includes | -includes) IFS=$nl pushv O INCLUDES; shift ;;
      --libs | -libs) IFS=$nl pushv O LIBS; shift ;;
        *) break ;;
    esac
  done
  : ${PATHCONV="${PATHTOOL:-echo}${PATHTOOL:+
-m}"}
  : ${O=NAME}
 evalcmd "ROOTS=\$(\${PATHCONV%%[^a-z]*} $ROOTS 2>/dev/null)" ROOTSCMD
 if [ "$NOCOLOR" = true ]; then
 unset ansi_{blue,bold,cyan,gray,green,magenta,none,red,yellow}
 fi
 sort -V <<<"$ROOTS" | while read -r CC; do
 CC=${CC%[!A-Za-z0-9.]}
 CC=${CC%"$CR"}
   THREADS= EXCEPTIONS= REV= RTVER= SNAP=
   TOOLEXE=
    case "$CC" in
      *x86_64*)
      ARCH="x86_64" ;;
      *i386*)
      ARCH="i386" ;;
      *i486*)
      ARCH="i486" ;;
      *i586*)
      ARCH="i586" ;;
      *i686*)
      ARCH="i686" ;;
      *)
      ARCH="" ;;
    esac
    TARGET=${CC##*/bin/}; TARGET=${TARGET%%gcc}
    TARGET=${TARGET%/}
    DIR="${CC%/*}"
    BASEDIR=${DIR%%/bin*}; BASEDIR=${BASEDIR%[!A-Za-z0-9./\\]}; BASEDIR="${BASEDIR%$CR}"
    BASEDIR=${BASEDIR%[\\\\/]} ;
    STDOUT=$(mktemp "$$-XXXXXX")
    STDERR=$(mktemp "$$-XXXXXX")
    trap 'rm -f "$STDOUT" "$STDERR"' EXIT
    CMD='"$CC" -dumpmachine 1>"$STDOUT" 2>"$STDERR"'
    DEBUG= evalcmd  '"$CC" -dumpmachine 1>"$STDOUT" 2>"$STDERR"' DUMPCMD
    OUT=$(<"$STDOUT")
    ERR=$(<"$STDERR")
    OUT=${OUT%"$CR"}
    ERR=${ERR%"$CR"}
    trap '' EXIT;  rm -f "$STDOUT" "$STDERR"
    [ "$DEBUG" = true ] && vdump OUT ERR
    HOST=${OUT%[!0-9A-Za-z]}
    HOST=${HOST%"$CR"}
     [ -z "$HOST" ] && { echo "ERROR: could not determine host" 1>&2
     vdump OUT ERR
     return 1
     }
    MINGW=${BASEDIR##*/}
    HOSTDIR=$BASEDIR/$HOST
     PFX=${DIR%%-[0-9]*}
    VER=${DIR#$PFX}
    VER=${VER%%/*}
    case "$VER" in
      *-win32-*) VER=${VER//-win32-/-}
      THREADS=win32 ;;
      *-posix-*) VER=${VER//-posix-/-}
      THREADS=posix ;;
    esac
    case "$VER" in
      *-seh-*) VER=${VER//-seh-/-}
      EXCEPTIONS=seh ;;
      *-sjlj-*) VER=${VER//-sjlj-/-}
      EXCEPTIONS=sjlj ;;
      *-dwarf-*) VER=${VER//-dwarf-/-}
      EXCEPTIONS=dwarf ;;
    esac
    VER=${VER#[!0-9]}
    case "$VER" in
      *-rt*) RTVER=${VER##*-rt}; RTVER=${RTVER%%-*} ; VER=${VER//rt$RTVER[!.0-9a-z]/}: RTVER=${RTVER#[!0-9a-z]}
      RTVER=${RTVER#v} ;;
    esac
    case "$VER" in
      *-snapshot*) SNAP=${VER##*-snapshot}; SNAP=${SNAP%%-*} ; VER=${VER//snapshot$SNAP[!.0-9a-z]/}: SNAP=${SNAP#[!0-9a-z]}
      SNAP=${SNAP#v} ;;
    esac
     case "$VER" in
      *-rev*) REV=${VER##*rev}; REV=${REV%%[-/]*} ; VER=${VER//rev$REV/}; REV=${REV#v} ; VER=${VER%-}
      REV=${REV%[!0-9A-Za-z]} ;;
    esac
    if [ -n "$TOOL" ]; then
    CMD=
      for T in $TOOL; do
      TVAR=${T//"+"/"x"}
        case "$T" in
          *make*)
          TOOLEXE="mingw32-make" ;;
        esac
        case "$T" in
          *"+"*)  O=${O//"$T"/"$TVAR"};  ;;
        esac
        evalcmd "TPATH=\$(ls -d {\"\$BASEDIR/bin\",\"\$BASEDIR/opt/bin\",\"\$HOSTDIR/bin\",\"\$BASEDIR\"/lib*/gcc/\$HOST/*}/\$T 2>/dev/null | head -n1)" TPATHCMD
        TPATH=${TPATH%"$CR"}
        TPATH=$($PATHCONV "$TPATH")
         evalcmd "TOOL_${TVAR}=\"\$TPATH\"" TOOL_$TVAR
      done
    fi
    INCLUDES="-I$($PATHCONV "${BASEDIR}/include") -I$($PATHCONV "${HOSTDIR}/include")"
    DEFS="-DNDEBUG=1"
    CPPFLAGS="$DEFS $INCLUDES"
    CXXFLAGS="-g -O2 -Wall -fexceptions -mthreads $CPPFLAGS"
    CFLAGS="-g -O2 -Wall -fexceptions -mthreads $CPPFLAGS"
    LIBS="-L$($PATHCONV "${BASEDIR}/lib") -L$($PATHCONV "${HOSTDIR}/lib") -lpthread"
    S=$'\n\t'
    EQ="="
    DQ="\""
    [ "$DEBUG" = true ] && #echo -e  "${ARCH:+${S}ARCH${EQ}${DQ}$ARCH${DQ}}${BASEDIR:+${S}BASEDIR${EQ}${DQ}$BASEDIR${DQ}}${CC:+${S}CC${EQ}${DQ}$CC${DQ}}${CFLAGS:+${S}CFLAGS${EQ}${DQ}$CFLAGS${DQ}}${CMD:+${S}CMD${EQ}${DQ}$CMD${DQ}}${DEBUG:+${S}DEBUG${EQ}${DQ}$DEBUG${DQ}}${DIR:+${S}DIR${EQ}${DQ}$DIR${DQ}}${DQ:+${S}DQ${EQ}${DQ}$DQ${DQ}}${EQ:+${S}EQ${EQ}${DQ}$EQ${DQ}}${EXCEPTIONS:+${S}EXCEPTIONS${EQ}${DQ}$EXCEPTIONS${DQ}}${HOST:+${S}HOST${EQ}${DQ}$HOST${DQ}}${HOSTDIR:+${S}HOSTDIR${EQ}${DQ}$HOSTDIR${DQ}}${I:+${S}I${EQ}${DQ}$I${DQ}}${IFS:+${S}IFS${EQ}${DQ}$IFS${DQ}}${L:+${S}L${EQ}${DQ}$L${DQ}}${LIBS:+${S}LIBS${EQ}${DQ}$LIBS${DQ}}${MINGW:+${S}MINGW${EQ}${DQ}$MINGW${DQ}}${NAME:+${S}NAME${EQ}${DQ}$NAME${DQ}}${NL:+${S}NL${EQ}${DQ}$NL${DQ}}${O:+${S}O${EQ}${DQ}$O${DQ}}${PATHCONV:+${S}PATHCONV${EQ}${DQ}$PATHCONV${DQ}}${PATHTOOL:+${S}PATHTOOL${EQ}${DQ}$PATHTOOL${DQ}}${PFX:+${S}PFX${EQ}${DQ}$PFX${DQ}}${PROGRAMFILES:+${S}PROGRAMFILES${EQ}${DQ}$PROGRAMFILES${DQ}}${REV:+${S}REV${EQ}${DQ}$REV${DQ}}${ROOTS:+${S}ROOTS${EQ}${DQ}$ROOTS${DQ}}${RTVER:+${S}RTVER${EQ}${DQ}$RTVER${DQ}}${SNAP:+${S}SNAP${EQ}${DQ}$SNAP${DQ}}${T:+${S}T${EQ}${DQ}$T${DQ}}${TARGET:+${S}TARGET${EQ}${DQ}$TARGET${DQ}}${THREADS:+${S}THREADS${EQ}${DQ}$THREADS${DQ}}${TOOL:+${S}TOOL${EQ}${DQ}$TOOL${DQ}}${TOOLEXE:+${S}TOOLEXE${EQ}${DQ}$TOOLEXE${DQ}}${TPATH:+${S}TPATH${EQ}${DQ}$TPATH${DQ}}${V:+${S}V${EQ}${DQ}$V${DQ}}${VARS:+${S}VARS${EQ}${DQ}$VARS${DQ}}${VER:+${S}VER${EQ}${DQ}$VER${DQ}}" 1>&2
    vdump " " ROOTS  O BASEDIR HOSTDIR HOST VER $O " "
    echo 1>&2
    NAME="MinGW ${VER}${ARCH:+ $ARCH}"
    for V in $O; do
    DEBUG=false  evalcmd "echo \"\${${V:-NAME}}\"" OUTVAR
    done
  done
  )
}
