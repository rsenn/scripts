#!/bin/bash

_cygpath()
{
    ( FMT="cygwin";
    IFS="
";
    while :; do
        case "$1" in
            -w)
                FMT="windows";
                shift
            ;;
            -m)
                FMT="mixed";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    unset CMD PRNT EXPR;
    case "$FMT" in
        mixed | windows)
            vappend EXPR 's,^/cygdrive/\(.\)\(.*\),\1:\2,'
        ;;
        cygwin)
            vappend EXPR 's,^\(.\):\(.*\),/cygdrive/\1\2,'
        ;;
    esac;
    case "$FMT" in
        mixed | cygwin)
            vappend EXPR 's,\\,/,g'
        ;;
        windows)
            vappend EXPR 's,/,\\,g'
        ;;
    esac;
    FLTR="${SED-sed} -e \"\${EXPR}\"";
    if [ $# -le 0 ]; then
        PRNT="";
    else
        PRNT="echo \"\$*\"";
    fi;
    CMD="$PRNT";
    [ "$FLTR" ] && CMD="${CMD:+$CMD|}$FLTR";
    echo "! $CMD" 1>&2;
    eval "$CMD" )
}

_msyspath()
{
 (add_to_script() { while [ "$1" ]; do SCRIPT="${SCRIPT:+$SCRIPT ;; }$1"; shift; done; }

  case $MODE in
    win*|mix*) #add_to_script "s|^${SYSDRIVE}[\\\\/]\(.\)[\\\\/]|\1:/|" "s|^${SYSDRIVE}[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
      add_to_script "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\\([\\\\/]\\)\\([^\\\\/]\\)\\?|\\1:\\2\\3|" "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\$|\\1:/|" ;;
    *) add_to_script "s|^\([A-Za-z0-9]\):|${SYSDRIVE}/\\1|" ;;
  esac
  case $MODE in
    win*|mix*)
      for MOUNT in $(mount | ${SED-sed} -n 's|\\|\\\\|g ;; s,\(.\):\\\(.\+\) on \(.*\) type .*,\1:\\\2|\3,p'); do
        DEV=${MOUNT%'|'*}
        MNT=${MOUNT##*'|'}
        test "$MNT" = / && DEV="$DEV\\\\"

        add_to_script "/^.:/! s|^${MNT}|${DEV}|"
       done

       #ROOT=$(mount | ${SED-sed} -n 's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      #add_to_script "/^.:/!  s|^|$ROOT|"
    ;;
  esac
  case "$MODE" in
    win32) add_to_script "s|/|\\\\|g" ;;
    *) add_to_script "s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) add_to_script "s|^${SYSDRIVE}/A/|${SYSDRIVE}/a/|" "s|^${SYSDRIVE}/B/|${SYSDRIVE}/b/|" "s|^${SYSDRIVE}/C/|${SYSDRIVE}/c/|" "s|^${SYSDRIVE}/D/|${SYSDRIVE}/d/|" "s|^${SYSDRIVE}/E/|${SYSDRIVE}/e/|" "s|^${SYSDRIVE}/F/|${SYSDRIVE}/f/|" "s|^${SYSDRIVE}/G/|${SYSDRIVE}/g/|" "s|^${SYSDRIVE}/H/|${SYSDRIVE}/h/|" "s|^${SYSDRIVE}/I/|${SYSDRIVE}/i/|" "s|^${SYSDRIVE}/J/|${SYSDRIVE}/j/|" "s|^${SYSDRIVE}/K/|${SYSDRIVE}/k/|" "s|^${SYSDRIVE}/L/|${SYSDRIVE}/l/|" "s|^${SYSDRIVE}/M/|${SYSDRIVE}/m/|" "s|^${SYSDRIVE}/N/|${SYSDRIVE}/n/|" "s|^${SYSDRIVE}/O/|${SYSDRIVE}/o/|" "s|^${SYSDRIVE}/P/|${SYSDRIVE}/p/|" "s|^${SYSDRIVE}/Q/|${SYSDRIVE}/q/|" "s|^${SYSDRIVE}/R/|${SYSDRIVE}/r/|" "s|^${SYSDRIVE}/S/|${SYSDRIVE}/s/|" "s|^${SYSDRIVE}/T/|${SYSDRIVE}/t/|" "s|^${SYSDRIVE}/U/|${SYSDRIVE}/u/|" "s|^${SYSDRIVE}/V/|${SYSDRIVE}/v/|" "s|^${SYSDRIVE}/W/|${SYSDRIVE}/w/|" "s|^${SYSDRIVE}/X/|${SYSDRIVE}/x/|" "s|^${SYSDRIVE}/Y/|${SYSDRIVE}/y/|" "s|^${SYSDRIVE}/Z/|${SYSDRIVE}/z/|"
    ;;
    win*)  add_to_script "s|^a:|A:|" "s|^b:|B:|" "s|^c:|C:|" "s|^d:|D:|" "s|^e:|E:|" "s|^f:|F:|" "s|^g:|G:|" "s|^h:|H:|" "s|^i:|I:|" "s|^j:|J:|" "s|^k:|K:|" "s|^l:|L:|" "s|^m:|M:|" "s|^n:|N:|" "s|^o:|O:|" "s|^p:|P:|" "s|^q:|Q:|" "s|^r:|R:|" "s|^s:|S:|" "s|^t:|T:|" "s|^u:|U:|" "s|^v:|V:|" "s|^w:|W:|" "s|^x:|X:|" "s|^y:|Y:|" "s|^z:|Z:|" ;;
  esac
  #echo "SCRIPT=$SCRIPT" 1>&2
 (${SED-sed} "$SCRIPT" "$@")
 )
}

absdir()
{
    case $1 in
        /*)
            echo "$1"
        ;;
        *)
            ( cwd=`pwd` && cd "$cwd${1:+/$1}" && echo "$cwd${1:+/$1}" || {
                cd "$1" && pwd
            } )
        ;;
    esac 2> /dev/null
}

abspath()
{
    if [ -e "$1" ]; then
        local dir=`dirname "$1"` && dir=`absdir "$dir"`;
        echo "${dir%/.}/${1##*/}";
    fi
}

add-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | ${SED-sed} 's,[/.],_,g' | tr '[[:'{lower,upper}':]]')

  ${SED-sed} -i "\\|^\s*#\s*include\s\+[<\"]\s*$INCNAME[>\"]| {
    s|.*|#ifdef $INCDEF\n&\n#endif /* defined $INCDEF */|
  }" "$@"

  )
}

addprefix() {
 (PREFIX=$1; shift
  CMD='echo "$PREFIX$LINE"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
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

all-disks()
{
   (case "$1" in
      -l) SHOW_LABEL=true; shift ;;
      -u) SHOW_UUID=true; shift ;;
    esac
    if [ -z "$1" ]; then
        set -- /dev/disk/by-{uuid,label};
    fi;
    find "$@" -type l | while read -r FILE; do
       if [ "$SHOW_LABEL" = true ]; then
   case "$FILE" in
       /dev/disk/by-label/*) echo "LABEL=${FILE##*/}" ;;
   esac
       elif [ "$SHOW_UUID" = true ]; then
   case "$FILE" in
       /dev/disk/by-uuid/*) echo "UUID=${FILE##*/}" ;;
   esac
       else
        myrealpath "$FILE";
       fi
    done | sort -u
    )
}

apt-dpkg-list-all-pkgs()
{
  require apt
  require dpkg

  apt_list >apt.list
  dpkg_list >dpkg.list

  dpkg_expr=^$(grep-e-expr $(<dpkg.list))

  awkp <apt.list >pkgs.list
  ${GREP-grep} -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}

arch2bit() {
 (for ARG; do
   case "$ARG" in
     *x64* | *x86?64*) echo 64 ;;
     *x86* | *i[3-6]86*) echo 32 ;;
     *) echo "No such arch: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}

: ${arm_linux_gnueabihf_CFLAGS="-march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4"}
: ${arm_linux_gnueabihf_CXXFLAGS=$arm_linux_gnueabihf_CFLAGS}

arm-linux-gnueabihf-make() { 
  (FNAME=${FUNCNAME[0]}
		CHOST=${FNAME%-make};
declare \
	CC="$CHOST-gcc${SYSROOT:+ --sysroot="$SYSROOT"}"  \
CXX="$CHOST-g++${SYSROOT:+ --sysroot="$SYSROOT"}" 

		for VAR in CCFLAGS CXXFLAGS ; do 
			eval "${VAR%FLAGS}=\"\$${VAR%FLAGS} \$${CHOST//-/_}_$VAR\""
		done

		set -- make CC="$CC" {CXX,CCLD,LINK}="$CXX" "$@" 

		if [ -n "$SYSROOT" -a -d "$SYSROOT" ]; then
		[ -z "$PKG_CONFIG_PATH" ] && export PKG_CONFIG_PATH="$(ls -d $SYSROOT/{usr/,}{lib/,share/}{,*/}pkgconfig 2>/dev/null |implode :)"
		[ -z "$PKG_CONFIG_SYSROOT_DIR" ] && export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
    fi
		[ "$DEBUG" = true ] && set -x

		"$@")
}

array()
{
    local IFS="$ARRAY_s";
    echo "$*"
}

asc2chr()
{
	(while :; do
	   case "$1" in
			   -n|-nonewline|--nonewline) NONL="-nonewline"; shift ;;
				 *) break ;;
			esac
		done
    CMD='echo "puts ${NONL:+$NONL }[format \"%c\" $ASC]"'
		CMD="for ASC; do $CMD; done | tclsh"
		eval "$CMD")
}

aspect()
{
    ( case "$#" in
        1)
            W="${1%%x*}" H="${1#*x}"
        ;;
        2)
            W="$1" H="$2"
        ;;
    esac;
    GCD=$(gcd "$W" "$H");
    echo "$((W / GCD)):$((H / GCD))" )
}

autorun-shell()
{
   (EXEC="$1"
     shift
     [ $# -le 0 ] && set -- $(echo "$EXEC" |${SED-sed} 's,Start,Start , ; s,\.exe,,g')
    echo "Shell\\Option1=$*
Shell\\Option1\\Command=$EXEC
")
}

awkp() {
 (IFS="
  "; N=${1}
  CMD="awk"
  [ $# -le 0 ] && set -- 1
  SCRIPT=""

  while :; do
    case "$1" in
      -[A-Za-z]*) CMD="$CMD $1"; shift ;;
      [0-9]) SCRIPT="${SCRIPT:+$SCRIPT\" \"}\$$1"; shift ;;
      [0-9]*) SCRIPT="${SCRIPT:+$SCRIPT\" \"}\$($1)"; shift ;;
      *) break ;;
    esac
  done
  eval "$CMD \"{ print \$SCRIPT }\"")
}

bheader()
{
    quiet dd count="${1:-1}" bs="${2:-512}"
}

bin2dec() {
  while [ $# -gt 0 ]; do
	eval 'echo "$((2#'${1#0b}'))"'
	shift
  done
}

bin2hex() {
  while [ $# -gt 0 ]; do
	eval 'printf "0x%02x\n" "$((2#'${1#0b}'))"'
	shift
  done
}

bit2arch() {
 (for ARG; do
   case "$ARG" in
     32 | 32[!0-9]* | *[!0-9]32 | *[!0-9]32[!0-9]*) echo x86 ;;
     64 | 64[!0-9]* | *[!0-9]64 | *[!0-9]64[!0-9]*) echo x64 ;;
     *) echo "No such bit count: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}

bitrate()
{
  mminfo "$@" | while read -r LINE; do
    INFO=${LINE##*:}
    KEY=${INFO%%=*}
    [ "$KEY" = "Overall bit rate" ] || continue 
    VALUE=${INFO#$KEY=*}
    [ "$INFO" = "$LINE" ] && FILE= || FILE=${LINE%%":$INFO"}
   
    #VALUE=$(suffix-num "${VALUE%"b/s"}")
    VALUE=${VALUE%"b/s"}
    VALUE=${VALUE/" "/""}
    echo "${FILE:+$FILE:}$VALUE"
  done
}

blksize()
{
    ( SIZE=`fdisk -s "$1"`;
    [ -n "$SIZE" ] && expr "$SIZE" \* 512 / ${2-512} )
}

blkvars()
{
  CMD=$(IFS=" "; set -- `blkid "$1"`; shift; echo "$*")
  shift
  if [ $# -gt 0 ]; then
    for V; do
      CMD="$CMD; echo \"\${$V}\""
    done
    CMD="($CMD)"
  fi
  eval "$CMD"
}

bpm() {
  id3v2  -l "$@"|${SED-sed} -n "/^id3v2 tag info for / {
    :lp
    N
    /\n[[:upper:][:digit:]]\+ ([^\n]*$/ {
      /\nTBPM[^\n]*$/! {
        s|\n[^\n]*$||
        b lp
      }
      s|TBPM (.*): ||g
      b ok
    }
    /:\s*$/! {
      s|\n| |g
      b lp
    }
    :ok
    s|\n[^\n]*:\s*$||
    s|^id3v2 tag info for \([^\n]*\) *: *\n *|\1: |
    p
  }"
}

 browser-shortcuts() { (cd "$(cygpath -am "$USERPROFILE/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch")";
 
  for T in $(list-mediapath 'PortableApps/*'{Firefox,Chrome}'*/*'{irefox,hrome}'*.exe'); do D=$(dirname "$T"); DN=$(basename "$D"); mkshortcut -i "/cygdrive/d/Icons/ico/$DN.ico" -n "$DN" "$T"; done) 
  }

build-arm-linux()
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

c256()
{
  value=$1
  value=$(( ((value & 0x0F) << 4) | ((value & 0xF0) >> 4) ))
  value=$(( ((value & 0x33) << 2) | ((value & 0xCC) >> 2) ))
  value=$(( ((value & 0x55) << 1) | ((value & 0xAA) >> 1) ))
  echo "$value"
}

c2w()
{
    ch-conv UTF-8 UTF-16 "$@"
}

canonicalize()
{
  (IFS="
 -"
   while :; do
   case "$1" in
     -l|--lowercase) LOWERCASE=true; shift ;;
     -m=|--maxlen=) MAXLEN="${1#*=}"; shift ;;
     -m|--maxlen) MAXLEN="$2"; shift 2 ;;
     *) break ;;
     esac
   done
     : ${MAXLEN:=4095}

   CMD="${SED-sed} 's,[^A-Za-z0-9],-,g'|${SED-sed} 's,-\+,-,g ;; s,^-\+,, ;; s,-\+\$,,'"
   [ "$LOWERCASE" = true ] && CMD="$CMD|tr [:{upper,lower}:]"
   #[ $# -gt 0 ] && CMD='set -- \$(IFS=" "; echo "$*"|'$CMD')'

   set -- $(echo "$*"|eval "$CMD")

   unset OUT

   while [ $# -gt 0 ]; do
      [ -z "$1" ] && continue
     NEWOUT="${OUT:+$OUT-}$1"
     [ ${#NEWOUT} -gt ${MAXLEN} ] && break
     OUT="$NEWOUT"
     shift
   done

   echo "$OUT"

   )
}

ch-conv()
{
    FROM="$1" TO="$2";
    shift 2;
    for ARG in "$@";
    do
        ( trap 'rm -f "$TMP"' EXIT;
        TMP=$(mktemp);
        iconv -f "$FROM" -t "$TO" <"$ARG" >"$TMP" && mv -vf "$TMP" "$ARG" );
    done
}

check-7z() {
 (while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  IFS="
"
  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }
  OUTDIR="$PWD/Check-$RANDOM"
  rm -rf "$OUTDIR"
  mkdir -p "$OUTDIR"
  trap 'rm -rf "$OUTDIR"' EXIT
  FILTER="xargs -n1 -d \"\${IFS:0:1}\" sha1sum"
  #FILTER="$FILTER | ${SED-sed} \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\${ARCHIVE}\${SEP:-: }\\2 \\[\\1\\]|\""
  FILTER="$FILTER | ${SED-sed} \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\\1 \\*\${ARCHIVE}\${SEP:-:}\\2|\""
  process() { IFS="
 "; set +x;
    unset PREV; while read -r LINE; do
    LINE=${LINE//"\\"/"/"}
     case "$LINE" in
     "Extracting: "*) ARCHIVE=${LINE#"Extracting: "}; echo "Archive=${ARCHIVE}" 1>&2; continue ;;
      "Extracting  "*)
          FILE=${LINE#"Extracting  "}
          if [ -n "$FILE" -a "$FILE" != "$PREV" ]; then
#				    echo "FILE='$FILE'" 1>&2
          [ "$FILE" = "$T" ] && continue
            if [ -e "$FILE" ]; then [ -f "$FILE" ] && echo "$FILE"
            else echo "File '$FILE' not found!" 1>&2; fi
          fi
        PREV="$FILE" ;;
     esac; done
  }
  while [ $# -gt 0 ]; do
   (B=${1##*/}
    case "$1" in
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
    esac
    case "$1" in
      *.t?z | *.tbz2)
        T=${1%.t?z}
        T=${T%.tbz2}
        T=$T.tar
        INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${T}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS"
        ;;
      *.tar.*) T=${1%.tar*}.tar;
      INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${B%.*}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS" ;;
      *) CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" -y $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    T=${T##*/}
    	    #echo "T='$T'" 1>&2
      if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si${1##*/}"
    fi
      CMD="($CMD) 2>&1 | (cd \"\$OUTDIR\" >/dev/null; process${FILTER:+ | $FILTER})"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
     eval "$CMD") || exit $?
    shift
  done)
}

check-link()
{
  (TARGET=$(readshortcut "$1")
    test -e "$TARGET")
}

choco-joinlines() {
 (LINENO=0
  o() {
    PKG=$1
    VERSION=$2
    shift 2
    DESC="$*"
    
#    echo "$PKG $VERSION - $DESC"
    s=$(printf "%-30s %-21s %s\n" "$PKG" "$VERSION" "${DESC%%. *}") #$(d=32 short "$DESC") 1>&2
    
    short "$s"
  }
   short() {   : ${COLS=$(tput cols)};   s=$*; if [ "${#s}" -gt "$COLS" ]; then s=${s:0:$((COLS - 3))}...; fi; echo "$s"; }
  
  while LINENO=$(($LINENO + 1)); IFS=""; 	read -r LINE; do
    LINE=${LINE%$'\r'}
    IFS=$' \t'
    set -- $LINE
    
    
    case "$LINE" in
      "#"*) LINE=" $LINE" ;;
      "["*) LINE=" $LINE" ;;
    esac
    case "$LINE" in
      " "*) set -- "" "$@" ;;
      *) LINE=${LINE%" [Approved]"*} ;;
    esac    
    if [ $# -eq 0 -a -n "$PKG" ]; then

      o "$PKG" "$VERSION" "$DESC"
      PKG= VERSION= DESC=      
    elif [ -z "$PKG" -a -z "$VERSION" -a $# -eq 2 -a -n "$1" -a -n "$2" ]; then
      PKG=$1
      VERSION=$2
      DESC=""
    else
      test -z "$1" && shift 
      case "$LINE" in
        *"Description:"*)
          DESC=${LINE#*"Description: "}
          ;;
        *Tags:* | *Downloads:*)  ;;
        " "*)
          if [ -n "$DESC" ]; then
            DESC="$DESC $*"
          fi
        ;;
      esac
    fi
  done)
}

choco-search()
{
 (R=1; trap 'echo "INT: $?"; exit $R' INT 
  EX=$(grep-e-expr "$@")
  IFS=" $IFS${nl}";
  while [ $# -gt 0 ] 2>/dev/null; do
   choco search -f -v $1  || break
    shift;
  done | choco-joinlines | (set -- ${GREP:-grep
--color=yes}; set -x; "$@" -i -E "$EX")
trap '' INT; exit 0)
}

choices-list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}

chr2hex()
{
    echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"${2-0x}%02x\" \${ascii}]" | tclsh
}

clamp()
{
    local int="$1" min="$2" max="$3";
    if [ "$int" -lt "$min" ]; then
        echo "$min";
    else
        if [ "$int" -gt "$max" ]; then
            echo "$min";
        else
            echo "$int";
        fi;
    fi
}

cleanup-desktop() {
 (mv -vf -- "$DESKTOP"/../../*/Desktop/* "$DESKTOP"
  cd "$DESKTOP"
  links=$( ls -ltdr --time-style=+%Y%m%d -- *.lnk|${GREP-grep} "$(date +%Y%m%d|removesuffix '[0-9]')"|cut-ls-l )
  set  -- $( ls -td -- $(ls-files|${GREP-grep} -viE '(\.lnk$|\.ini$)'))
  touch "$@"
  mv -vft "$DOCUMENTS" "$@" *" - Shortcut"*
  d=$(ls -d  ../Unused* )

  for l in $links; do
    while :; do
      read -r -p "Move ${l##*/} to $d? " ANS
			case "$ANS" in
                            y*|j*|Y*|J*) mv -vi -t $(cygpath -a "$USERPROFILE")/Unused*Shortcuts*/ "$l" ;;
				n*|N*) ;;
				*) continue ;;
			esac
			break
    done

  done
  )
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
cmake_args() {
 (for BUILDDIR; do
    sed -n '
    /-ADVANCED/d
    /-NOTFOUND/d
    /=$/d
    s|:[^=]*=\(.*\)|="\1"|p
  
  ' "$BUILDDIR"/CMakeCache.txt
  done)
}

<<<<<<< HEAD
=======
cmake_sourcedir() {
 (for BUILDDIR; do
    sed -n '
    /^CMAKE_SOURCE_DIR/!d 
    s|^[^=]*=||p
  
  ' "$BUILDDIR"/CMakeVars.txt
  done)
}

=======
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
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
        cmdexec -m -o make.log make -C $builddir/      || { ERR=$?; ${GREP-grep} '(Stop|failed|error:)' -E  -C3 make.log; return $?; }
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

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
cmake_args() {
 (for BUILDDIR; do
    sed -n '
    /-ADVANCED/d
    /-NOTFOUND/d
    /=$/d
    s|:[^=]*=\(.*\)|="\1"|p
  
  ' "$BUILDDIR"/CMakeCache.txt
  done)
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
cmake_sourcedir() {
 (for BUILDDIR; do
    sed -n '
    /^CMAKE_SOURCE_DIR/!d 
    s|^[^=]*=||p
  
  ' "$BUILDDIR"/CMakeVars.txt
  done)
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
cmd-path()
{ 
   (F=`mktemp`
    trap 'rm -vf --  "$F"' EXIT
    type "$1" 2>&1 >"$F" ; R=$?

    case "$R" in
        1) return 1 ;;
        0)  ;;
        *) exit $R ;;
    esac
    O=$(<"$F"); rm -f "$F"; trap '' EXIT

    
    case "$O" in
        *" is /"*) P=${O#*" is "} ;;
        *" is hashed \("*) P=${O#*"\("}; P=${P%"\)"} ;;
    esac

    if [ -n "$P" -a -e "$P" ]; then
        echo "$P"
    else
        return 127
    fi)
}

cmdprint() { 
 (unset O;
  while :; do
    case "$1" in
      -*) pushv OPTS "$1"; shift ;;
      *) break ;;
    esac
  done
  for A; do
    case "$A" in 
      *\ *) O=${O+$O }'$A' ;;
      *) O=${O+$O }$A ;;
    esac
  done
  echo $OPTS "$O")
}

command-exists()
{
    type "$1" 2> /dev/null > /dev/null
}

compare-dirs()
{
     diff -ru "$@" | ${SED-sed} -n \
         -e "/^Binary files/ s,^Binary files \(.*\) and \(.*\) differ, ,p" \
         -e "s,^Only in \(.*\): \(.*\),/,p" \
         -e "/^diff/ { N; /---/ { N; /+++/ { s,.*,, ; s,^diff\s\+,, ; s,^-[^ ]* ,,g ; p } } }"
}

conf_mingw()
{ 
    unset prefix;
    if [ $# -lt 1 ]; then
      set -- $(ls -d -- /usr/bin/*mingw*gcc.exe /mingw*/bin/gcc.exe 2>/dev/null)
    fi
    if [ $# -gt 1 ]; then
      eval "set -- \${$#}"
    fi
    
    for CCPATH; do
    test -d "$CCPATH" && CCPATH=$CCPATH/bin/gcc
        target=$("$CCPATH" -dumpmachine);
        target=${target%''};
        case "$target" in 
            *-mingw*)
                prefix=$( $CC -print-search-dirs|grep libr|removeprefix '*: '|sed 's,=,, ; s,:,\n,g'|xargs realpath 2>/dev/null|sort -f -u |grep 'sys.\?root' |removesuffix /lib)
                : ${prefix:="${CCPATH%%/bin*}"};
		MSYSTEM=MINGW
                break
            ;;
    *-msys*)
		MSYSTEM=MSYS
	    ;;
        esac;
    done;
    if [ -n "$prefix" -a -d "$prefix" ]; then
        [ -n "$host" ] && build="$host";
        host="$target";
        
        sys=$(cygpath -am /|sed 's,.*/,, ; s,-,,g')
        case "$sys" in
          gitsdk*|msys*) builddir="build/$sys" ;;
          *)    builddir="build/$host" ;;
        esac
        pathmunge -f "$prefix/bin";
        CC="${CCPATH##*/}"
        CC=${CC%.exe}
        CXX=${CC/gcc/g++}
        export CC CXX
        unset PKG_CONFIG_PATH;
        init_pkgconfig_path;
    fi
    if [ -e "/usr/bin/pkgconf.exe" ]; then
	    export PKG_CONFIG="/usr/bin/pkgconf"
    fi
    if [ -d "$prefix/lib/pkgconfig" ]; then
	    export PKG_CONFIG_PATH="$prefix/lib/pkgconfig"
    fi
}

config-disable() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|# ${ENTRY## } is not set|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}

config-enable() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|${ENTRY## }=y|"
	  echo "\\|# ${ENTRY## } is not set| s|.*|${ENTRY## }=y|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}

config-module() {
 (CFG="$1"
  shift
  trap 'rm -f "$TMP"' EXIT
  TMP=`mktemp`
  for ENTRY in "${@%%[ =]*}"; do
	  echo "\\|^${ENTRY## }=| s|.*|${ENTRY## }=m|"
	  echo "\\|# ${ENTRY## } is not set| s|.*|${ENTRY## }=m|"
  done >$TMP
  sed -i -f "$TMP" "$CFG")
}

convert-boot-entries()
{
  ([ -z "$FORMAT" ] && FORMAT="$1"

    for FILE; do
      convert-boot-file "$FILE" "$FORMAT"
    done
  )
}

convert-boot-file()
{
  (if [ -e "$1" ]; then
     exec <"$1"
     shift
   fi

   [ -z "$FORMAT" ] && FORMAT="$1"

   while parse-boot-entry; do
     output-boot-entry "$FORMAT"
   done



   )
}

count() {
        echo $#
}

count-in-dir()
{
         (LIST="$1"; shift; for ARG; do
         N=$(${GREP-grep} "^${ARG%/}/." "$LIST" | wc -l)
         echo $N "$ARG"
 done)
}

count-lines()
{
    ( [ $# -le 0 ] && set -- -;
    N=$#;
    for ARG in "$@";
    do
        ( set -- $( (xzcat "$ARG" 2>/dev/null ||zcat "$ARG" 2>/dev/null || bzcat "$ARG" 2>/dev/null || cat "$ARG") | wc -l);
        [ "$N" -le 1 ] && echo "$1" || printf "%10d %s\n" "$1" "$ARG" );
    done )
}

countv()
{
  (eval "set -- \${$1}; echo \$#")
}

cpan-install()
{
    for ARG in "$@";
    do
        perl -MCPAN -e "CPAN::Shell->notest\('install', '$ARG'\)";
    done
}

cpan-inst() {
 for-each 'verbosecmd -1+=cpan.inst.log -2=1 cpan -i "${1//-/::}" ;  verbosecmd writefile -a cpan.inst.$? "$1"'  ${@:-$(<~/cpan-inst.list)}
}

cpan-search()
{
    ( for ARG in "$@";
    do
        ARG=${ARG//::/-};
        URL=`dlynx.sh "http://search.cpan.org/search?query=$ARG&mode=dist" |${GREP-grep
-a} "/$ARG-[0-9][^/]*/\$" | sort -V | tail -n1 `
        test -n "$URL" && {
            dlynx.sh "$URL" | grep-archives.sh | sort -V | tail -n1
        };
    done )
}

chr2dec() {
    echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"%d\" \${ascii}]" | tclsh
}

create-win-kbd-shortcut() {
  N=0; for A; do case "$A" in
      "ALT" | "alt") N=$((N | 0x00140000)) ;;
      "CTRL" | "ctrl" | "CONTROL" | "control") N=$((N | 0x00120000)) ;;
      "SHIFT" | "shift") N=$((N | 0x00110000)) ;;
      ?) N=$(( N | $(chr2dec "$A") )) ;;
    esac; done; printf "%d" "$N"
    ([ "$DEBUG" = true ] && echo + create-win-kbd-shortcut "$@" "$(printf "(=0x%02x/%d)\n" "$N" "$N"))" 1>&2
 
 )
}

create-qttabbar-applications() { 
 ( : ${SPACE=" "}
   : ${BS="\\"}
   : ${NL="
"}; kbdcode=65
    tmpfile=$(mktemp)
   trap 'rm -f "$tmpfile"' EXIT
echo "REGEDIT4"
  echo
  echo '[HKEY_CURRENT_USER\Software\Quizo\QTTabBar\AppLauncher]'
  for file; do
    file=$(realpath "$file")
    fn=${file##*/}
    case "$file" in
      *.lnk)  winpath=$(cygpath -aw "$(readshortcut "$file")");name=$(basename "$file" .lnk); workdir=$(readshortcut -g "$file") ;;
      *) winpath=$(cygpath -aw "$file"); name=$(basename "${file%.*}"); name=${name##*Start};  workdir=${file%/*} ;;
    esac 
    case "$file" in
      Start?*.exe) arg="%C%" ;;
      *) arg="" ;;
    esac
     #workdir=$(cygpath -aw "$workdir")
     case "$workdir" in 
       *:) workdir="$workdir/" ;;
     esac
     workdir=${workdir//"/"/"\\\\"}
     if [ -n "$kbdcode" -a "${kbdcode:-0}" -gt 0 ] 2>/dev/null; then
       [ "$kbdcode" -eq 57 ] && kbdcode= key=0 ||   kbdcode=$((kbdcode+1))
       [ "$kbdcode" -gt 90 ] && kbdcode=49
     fi
     
     if [ -n "$kbdcode" -a "${kbdcode:-0}" -gt 0 ] 2>/dev/null; then
       winkbd=$(list SHIFT ALT $(asc2chr "$kbdcode"))
     else
       winkbd=
     fi
     

     [ -n "$winkbd" ] && key="$(create-win-kbd-shortcut $winkbd)" || key=0
     
     [ "$DEBUG" = true ] && echo "file='$file' name='$name' arg='$arg' kbdcode='$kbdcode' winkbd='${winkbd//$NL/$SPACE}' key='$key'" 1>&2
     
     echo -n -e "${winpath//$BS/$BS$BS}\x00${arg//$BS/$BS$BS}\x00${workdir//$BS/$BS$BS}\x00${key}\x00\x00\x00" >"$tmpfile"
     [ "$DEBUG" = true ] && sed "s,\\\\,\\\\\\\\,g; s,\\x00,|,g ; s|.*|regstr='&'\n|" "$tmpfile" 1>&2
     #hexdump -C <"$tmpfile" 1>&2
   (set -- $( hexdump -C <"$tmpfile" |
      sed '
        s,|.*,,
        s,^\s\+,,
        s,\s\+, ,g
        :lp
        N
        $! { b lp }
        s,[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]\+\s*,,g
        s,|[^\n]*\n,,g
        s,\s\+,\n,g
        p
      ' -n)
    echo "\"$name\"=hex(7):$(implode , <<<"$*")" 
   )
  done) | unix2dos
}

create-shortcut()
{
 (declare "$@"
  (set -x; mkshortcut ${ARGS:+-a
"$ARGS"} ${ICON:+-i
"$ICON"} ${ICONOFFSET:+-j
"$ICONOFFSET"} ${DESC:+-d
"$DESC"} ${NAME:+-n
"$NAME"} ${WDIR:+-w
"$WDIR"} \
"$TARGET")
  )
}

 create-shortcuts() { (cd "$(cygpath -am "$USERPROFILE/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch")";
 
  for T in $(list-mediapath 'PortableApps/*'{Firefox,Chrome}'*/*'{irefox,hrome}'*.exe'); do D=$(dirname "$T"); DN=$(basename "$D"); mkshortcut -i "/cygdrive/d/Icons/ico/$DN.ico" -n "$DN" "$T"; done) 
  }

cropdetect-parse() {

 (while read -r LINE; do
    (IFS=" "; set -- ; for DATA in $LINE; do
       case "$DATA" in
  *=*) set -- "$@" $DATA ;;
   *:[0-9]*) set -- "$@" ${DATA%%:*}=${DATA#*:} ;;
esac
done
echo "$@" )

  done)
}

ctime()
{
    ( TS="+%s";
    while :; do
        case "$1" in
            +*)
                TS="$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    NW="[^ ]\+";
    WS=" \+";
    E="^${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E\(${NW}\)${WS}";
    E="$E\(.*\)";
    [ $# -gt 1 ] && R="\2: \1" || R="\1";
    ls --color=auto --color=auto --color=auto -l -n -d --time=ctime --time-style="${TS}" "$@" | ${SED-sed} "s/$E/$R/" )
}

cut-arch()
{
    ${SED-sed} 's,^\([^ ]*\)\.[^ .]*\( - \)\?\(.*\)$,\1\2\3,'
}

cut-basename()
{
    ${SED-sed} 's,[/\\][^/\\]*[/\\]\?$,,'
}

cut-dirname()
{
    ${SED-sed} "s,\\(.*\\)[/\\\\]\\([^/\\\\]\\+[/\\\\]\\?\\)${1//./\\.}\$,\2,"
}

cut-distver()
{
  cat "$@" | ${SED-sed} 's,\.fc[0-9]\+\(\.\)\?,\1,g'
}

cut-dotslash()
{
  ${SED-sed} -u 's,^\.[/\\],,'
}

cut-ext() {
 (CMD='${SED-sed} -e "/\\.exe\$/ { s|\\.paf\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.gz\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.bz2\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.lzma\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.xz\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.Z\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "s,\\.[^./]\\+\$,,"'
  CMD="$CMD${@:+ \"\$@\"}"
  eval "$CMD")
}

cut-hexnum()
{
  ${SED-sed} 's,^\s*[0-9a-fA-F]\+\s*,,' "$@"
}

cut-ls-l()
{
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD='while read  -r '$*' P;do  echo "$P"; done'
   #echo "+ $CMD" 1>&2;
    eval "$CMD" )
}



cut-num() {
 (unset N
 while :; do
    case "$1" in
      -n | --num) N="$2"; shift 2 ;;
      -n=* | --num=*) N="${1##*=}"; shift ;;
      -n) N="${1#-n}"; shift ;;
      *) break ;;
    esac
  done
  : ${N=1}
  EXPR=
  while [ $((N)) -gt 0 ]; do
    EXPR="$EXPR[0-9]\\+\\s*"
    : $((N--))
  done
  ${SED-sed} "s|^${EXPR:+\\s*$EXPR}||" "$@")
}

cut-pkgver()
{
    cat "$@" |${SED-sed} 's,-[0-9]\+$,,g'
}

cut-trailver() {
 (CMD='${SED-sed} -e "s|[-_][0-9][^-_.]*\\(\\.[0-9][^-.]*\\)*\$||" -e "s|[-_.]\\?[0-9]\\+\.[.0-9]\+\$||"'
  CMD="$CMD${@:+ \"\$@\"}"
  eval "$CMD")
}

cut-ver()
{ 
    cat "$@" |
	cut-trailver |
	sed 's,[-.]rc[[:alnum:]~][^-.]*,,g ;; s,[-.]b[[:alnum:]~][^-.]*,,g ;; s,[-.]git[_[:alnum:]~][^-.]*,,g ;; s,[-.]svn[_[:alnum:]~][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]~][^-.]*,,g ;; s,[-.]beta[_[:alnum:]~][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]~][^-.]*,,g ;; s,[-.]a[_[:alnum:]~][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]~][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]~][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]~][^-.]*,,g' |
	sed 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' |
	sed 's,\.\(P\)\?[[:digit:]][_+[:digit:]]*\.,.,g' |
	sed 's,-\([0-9]\+\):\([0-9]\+\),-\1.\2,' |
	sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]][_+[:alnum:]~]*\([-.]\),\1,g' |
	sed 's,[-_.][[:digit:]]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[[:digit:]][_+[:digit:]]*\(-.\),\5,g' |
	sed 's,-[[:digit:]][._+[:digit:]]*$,, ;;  s,-[[:digit:]][._+[:digit:]]*$,,' |
	sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]]*\(rc[[:digit:]]\)\?\(b[[:digit:]]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[[:digit:]]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[[:digit:]][_+[:alnum:]~]*\.,.,g' |
	sed 's,\.[[:digit:]][^.]*\.,.,g'
}

_cygpath()
{
    ( FMT="cygwin";
    IFS="
";
    while :; do
        case "$1" in
            -w)
                FMT="windows";
                shift
            ;;
            -m)
                FMT="mixed";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    unset CMD PRNT EXPR;
    case "$FMT" in
        mixed | windows)
            vappend EXPR 's,^/cygdrive/\(.\)\(.*\),\1:\2,'
        ;;
        cygwin)
            vappend EXPR 's,^\(.\):\(.*\),/cygdrive/\1\2,'
        ;;
    esac;
    case "$FMT" in
        mixed | cygwin)
            vappend EXPR 's,\\,/,g'
        ;;
        windows)
            vappend EXPR 's,/,\\,g'
        ;;
    esac;
    FLTR="${SED-sed} -e \"\${EXPR}\"";
    if [ $# -le 0 ]; then
        PRNT="";
    else
        PRNT="echo \"\$*\"";
    fi;
    CMD="$PRNT";
    [ "$FLTR" ] && CMD="${CMD:+$CMD|}$FLTR";
    echo "! $CMD" 1>&2;
    eval "$CMD" )
}

datasheet-url() {
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | ${GREP-grep} -i "$1[^/]*$"
}

date2unix()
{
    date --date "$1" "+%s"
}

debug()
{
    [ "$DEBUG" = true ] && echo "DEBUG: $@" 1>&2
}

dec2bin() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$\(\($N\)\)" ;;
    esac
    echo "obase=2;$N" | bc -l
  done | addprefix "${P-0b}")
}

decode-ar() {
  : ${HANDLER='7z x -si"$N" -so | tar -t'}
  : ${UNTIL='data.tar*'}

  read -r DATA
  if [ "$DATA" != '!<arch>' ]; then
    exec -<&0 # close stdin
    return 1
  fi
  
  
  while IFS=$' \t\r' read -r N T U G M S; do
    echo "Name: $N Date: $(date --date="@$T" +"%Y%m%d %H:%M:%S") UID: $U GID: $G Mode: $M Size: $S" 1>&2
    S=${S%%[!0-9]*}

     case "$N" in
       $UNTIL)   [ -n "$HANDLER" ] && eval "$HANDLER"; return 0 ;;
    esac

    for I in `seq 1 $((S-1))`; do
      IFS=  read -r -s -d '' -n 1 D
    done

  done
}

decompress()
{
    local mime="$(file -bi "$1")";
    case $mime in
        application/x-bzip2)
            bzip2 -dc "$1"
        ;;
        application/x-gzip)
            gzip -dc "$1"
        ;;
        *)
            cat "$1"
        ;;
    esac
}

decompress-7z() {
 (while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#

  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }

  [ $# -le 0 ] && set -- -

  while [ $# -gt 0 ]; do
   (case "$1" in
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
      -) OPTS="${OPTS:+$OPTS }-si" ;;
    esac
    OPTS=${OPTS:+$OPTS }"-so"
    CMD="7z x \$OPTS ${ARCHIVE+\"\$ARCHIVE\"}"
    eval "$CMD" )
    shift
  done)
}

<<<<<<< HEAD
dec-to-hex() { 
  (for N; do printf "${D2XPFX}%08x\n" "$N"; done)
=======
decompress()
{
    local mime="$(file -bi "$1")";
    case $mime in
        application/x-bzip2)
            bzip2 -dc "$1"
        ;;
        application/x-gzip)
            gzip -dc "$1"
        ;;
        *)
            cat "$1"
        ;;
    esac
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
}

dec-to-hex() { 
  (for N; do printf "${D2XPFX}%08x\n" "$N"; done)
}
dec2hex() { dec-to-hex "$@"; }

destdir() { 
	CCHOST=$(IFS="$IFS "; ${CC-cc} -dumpmachine);
	case "$CC:$CCHOST" in 
	*diet*:*)
	    PKGARCH=diet
	;;
	*:*linux*)
	    PKGARCH=linux
	;;
	*:*)
	    PKGARCH=$(IFS="$IFS -"; set -- $CCHOST; echo "${2:-$1}")
	;;
	esac;
	case "$CCHOST" in 
	i[3-6]86*)
	    PKGARCH="${PKGARCH}32"
	;;
	x86?64*)
	    PKGARCH="${PKGARCH}64"
	;;
	*)
	    PKGARCH="${CCHOST%%-*}-${PKGARCH}"
	;;
	esac;
	echo "$PWD-$PKGARCH"
}

detect-filesystem()
{
    if [ -e "$1" ]; then
        filesystem-for-device "$(device-of-file "$1")";
    fi
}

detect-system() {
  case ${MACHINE:=`uname -m`} in
    *64) BITS=64 ;;
    *) BITS=32 ;;
  esac
  case `which gcc` in
    */mingw*/bin/gcc*) SYS=$(which gcc); SYS=${SYS%%/bin*}; SYS=${SYS##*/} ;;
    *)  case ${OS:=`uname -o`} in
		  [Mm][Ss][Yy][Ss]*) 
			ROOT=`cygpath -am /`
			SYS=`basename "${ROOT}"`
			
			;;
		  *) SYS=`uname -o | tr "[[:upper:]]" "[[:lower:]]"`
		   ;;
		esac
	  ;;
  esac
  SYS=${SYS%%[36][24]*}
  SYS=${SYS//"-"/""}
  echo "$SYS$BITS"
}

device-by-uuid() {
  (P='$(blkid -U "$ARG" || realpath /dev/*/by-uuid/"$ARG")'
  [ $# -gt 1 ] && P='"$ARG:" '$P ; P='echo '$P
  for ARG; do eval "$P"; done)
}

device-of-file() {
 (while [ $# -gt 0 ]; do
    case "$1" in
      -d|--device) COL=1;  shift ;;
      -t|--type) COL=2;  shift ;;
      -s|--size) COL=3;  shift ;;
      -u|--used) COL=4;  shift ;;
      -a|--avail*) COL=5;  shift ;;
      -p|--percent) COL=6;  shift ;;
      -m|--mnt*|--mount*) COL=7 ; shift ;;
      *) break ;;
    esac
  done
  for ARG; do
  (if [ -e "$ARG" ]; then
     if [ -L "$ARG" ]; then
         ARG=`myrealpath "$ARG"`
     fi
     if [ -b "$ARG" ]; then
         echo "$ARG"
         exit 0
     fi
     if [ ! -d "$ARG" ]; then
         ARG=` dirname "$ARG" `
     fi
     DEV=`( : ${GREP-grep} -E "^[^ ]*\s+$ARG\s" /proc/mounts ;  df "$ARG" |${SED-sed} '1d' )|awkp ${COL-1}|head -n1`
     [ $# -gt 1 ] && DEV="$ARG: $DEV"

     [ "$DEV" = rootfs -o "$DEV" = /dev/root ] && DEV=`get-rootfs`

     echo "$DEV"
  fi)
  done)
}

diffcmp()
{
 (unset OPTS; while :; do
    case "$1" in
      --) shift; break ;;
      -*) OPTS="${OPTS+$OPTS$IFS}$1"; shift ;;
      *) break ;;
    esac
  done
  unset DIREXPR
  for ARG; do
    test -d "$ARG" || ARG=`dirname "$ARG"`
    DIREXPR="${DIREXPR+$DIREXPR ;; }s|^${ARG%/}/||"
  done

  LANGUAGE=C LC_ALL=C \
  diff $OPTS "$@" |
  ${SED-sed} -n \
    -e 's/^Binary files \(.*\) and \(.*\) differ/\1\n\2/p' \
    -e 's,^[-+][-+][-+]\s\+"\([^"]\+\)"\s.*,\1,p' \
    -e 's,^[-+][-+][-+]\s\+\([^"][^ \t]*\)\s.*,\1,p' \
    | ${SED-sed} -e "$DIREXPR" \
    | uniq)
}

diff-plus-minus()
{
    local IFS="$newline" d=$(diff -x .svn -ruN "$@" |
      ${SED-sed} -n -e "/^[-+][-+][-+]\s\+$1/d"                -e "/^[-+][-+][-+]\s\+$2/d"                -e '/^[-+]/ s,^\(.\).*$,\1, p' 2>/dev/null);
    IFS="-$newline ";
    eval set -- $d;
    local plus=$#;
    IFS="+$newline ";
    eval set -- $d;
    local minus=$#;
    echo "+$plus" "-$minus"
}

disk-device-for-partition()
{
    echo "${1%[0-9]}"
}

disk-device-letter()
{
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:2:1}"
}

disk-device-number()
{
    index_of "$(disk-device-letter "$1")"  a b c d e f g h i j k l m n o p q r s t u v w x y z
}

disk-devices() {
  wmic volume get DeviceID /VALUE | while read -r LINE; do
    case "$LINE" in
      *=*) echo "${LINE##*=}" ;;
    esac
  done
} ||

disk-devices() {
    foreach-partition 'echo "$DEV"'
}

diskfree()
{
    set -- `df -B1 -P "$@" | tail -n1`;
    echo $4
}

disk-label() {

 (if type blkid >/dev/null; then

    O=$(blkid "$1" )
    eval "${O#*:}"
    echo "$LABEL"
  else

  LABEL=`volname "$1"`
  if [ -n "$1" -a -e "$1" -a -n "$LABEL" ]; then
    echo "$LABEL"
    exit 0
  fi
  ESCAPE_ARGS="-e"
  while :; do
    case "$1" in
      -E | --no-escape) ESCAPE_ARGS=; shift ;;
      *) break ;;
    esac
  done
  DEV=${1}
  test -L "$DEV" && DEV=` myrealpath "$DEV"`
  cd /dev/disk/by-label
  find . -type l | while read -r LINK; do
    TARGET=`readlink "$LINK"`
    if [ "${DEV##*/}" = "${TARGET##*/}" ]; then
      NAME=${LINK##*/}
      NAME=${NAME//'\x20'/'\040'}
      case "$NAME" in
        *[[:lower:]]*) LOWER=true ;;
      esac
      if [ "$LOWER" = true -o ! -r "$LINK" ]; then
        echo $ESCAPE_ARGS "$NAME"
      else
        FS=` filesystem-for-device "$DEV"`
        case "$FS" in
          *fat)
              IFS="
"
            set -- $(dosfslabel "$LINK")
            test $# = 1 && echo "$1"
          ;;
          *) echo $ESCAPE_ARGS "$NAME" ;;
        esac
      fi
      exit 0
    fi
  done
  exit 1
  fi)
}

disk-partition-number()
{
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:3:1}"
}

disk-size()
{
    ( while :; do
        case "$1" in
            -m | -M)
                DIV=1024;
                shift
            ;;
            -g | -G)
                DIV=1048576;
                shift
            ;;
            -k | -K)
                DIV=1;
                shift
            ;;
            -b | -B)
                MUL=1024;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    R=$(sfdisk -s "$1");
    echo $(( R * ${MUL-1} / ${DIV-1} )) )
}

divide-resolution()
{
    ( WIDTH=${1%%${MULT_CHAR-x}*};
    HEIGHT=${1#*${MULT_CHAR-x}};
    echo $((WIDTH / $2))${MULT_CHAR-x}$((HEIGHT / $2)) )
}

dl-slackpkg()
{
  (: ${DIR=/tmp}
   for PKG; do
     BASE=${PKG##*/}

wget -P "$DIR" -c "$PKG" && installpkg "$DIR/$BASE"|| break
  done)
}

dospath()
{
    ( case "$1" in
        ?:*)
            set -- /cygdrive/${1%%:*}${1#?:}
        ;;
    esac;
    echo "$1" )
}

dump-lynx() {
 (IFS="
"
  while :; do
    case "$1" in
      -x | -debug | --debug) DEBUG=true; shift ;;
      -d | -dump | --dump)  DUMP=true; shift ;;
      -w | -wrap | --wrap)  WRAP=true; shift ;;
      -c | --config) pushv LYNX_CONFIG "$2"; shift 2 ;; -c=* | --config=*) pushv LYNX_CONFIG "${1#*=}"; shift ;; -c*) pushv LYNX_CONFIG "${1#-?}"; shift ;;
      -p | --proxy) export http_proxy="$2"; shift 2 ;; -p=* | --proxy=*) export http_proxy="${1#*=}"; shift ;; -p*) export http_proxy="${1#-?}"; shift ;;
      -C | --cookie) COOKIE_FILE="$2"; shift 2 ;; -C=* | --cookie=*) COOKIE_FILE="${1#*=}"; shift ;; -C*) COOKIE_FILE="${1#-?}"; shift ;;
      -A | --user*agent) USER_AGENT="$2"; shift 2 ;; -A=* | --user*agent=*) USER_AGENT="${1#*=}"; shift ;; -A*) USER_AGENT="${1#-?}"; shift ;;
      *) break ;;
   esac
 done

  : ${USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"}

  if [ "$DUMP" = true ]; then
     OPTS="-nolist"
     if [ "$WRAP" != true ]; then
       OPTS="$OPTS -width=65536"
     fi
  else
    OPTS="-listonly"
  fi

  if [ -n "$LYNX_CONFIG" ]; then
    TMPCFG=`mktemp dump-lynx-XXXXXX.cfg`
    trap 'rm -f "$TMPCFG"' EXIT
    echo "$LYNX_CONFIG" >"$TMPCFG"
    OPTS="$OPTS -cfg=\"\$TMPCFG\""
  fi

  CMD="lynx -accept_all_cookies${USER_AGENT:+ -useragent=\"\$USER_AGENT\"}${COOKIE_FILE:+ -cookie_file=\"\$COOKIE_FILE\"} $OPTS -nonumbers -hiddenlinks=merge \"\$URL\" 2>/dev/null"

  for URL; do
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD"
  done)
}

dump-shortcuts() {
 (while :; do
   case "$1" in
    -*) pushv OPTS "$1"; shift ;;
     *) break ;;
   esac
  done
  for-each 'readshortcut $OPTS -t -r "$1" | ${SED-sed} "N ; s%\s*
\s*% % ; s%^%$1: %"' "$@"
 )
}

duration()
{
    ( IFS=" $IFS";
      CMD='echo "${ARG:+$ARG:}$S"'
    while :; do
       case "$1" in
         -m | --minute*) CMD='echo "${ARG:+$ARG:}$((S / 60))"' ; shift ;;
       *) break ;;
     esac
   done
    N="$#";
    for ARG in "$@"
    do
        D=$(mminfo "$ARG" |${SED-sed} -n 's,Duration=,,p' | head -n1);
        set -- $D;
        S=0;
        for PART in "$@";
        do
            case $PART in
                *ms)
                    S=$(( (S * 1000 + ${PART%ms}) / 1000))
                ;;
                *mn|*m | *min)
                    PART=${PART%%[!0-9]*};
                    S=$((S + $PART * 60))
                ;;
                *h)
                    S=$((S + ${PART%h} * 3600))
                ;;
                *s)
                    S=$((S + ${PART%s}))
                ;;
            esac;
        done;
        [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD"
    done )
}

du-txt() {
 (IFS="
"; TMP="du.tmp$RANDOM"
  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      -0 | --null | -a | --all | --apparent-size | -c | --total | -D | --dereference-args | --summarize | -H | --dereference-args | -h | --human-readable | --inodes | -L | --dereference | -l | --count-links | -P | --no-dereference | -S | --separate-dirs | --si | -h | -s | --summarize | --time | -x | --one-file-system | --help | --version | --block-size) pushv DU_ARGS "$1"; shift ;;
      -B=* | -b=* | -d=* | -k=* | -m=* | -t=* | -X=*) pushv DU_ARGS "${1%%=*}" "${1#-?=}"; shift ;;
      -B | -b | -d | -k | -m | -t | -X) pushv DU_ARGS "$1" "$2"; shift 2 ;;
      -B* | -b* | -d* | -k* | -m* | -t* | -X*) A=${1#-?}; pushv DU_ARGS "${1%%$A}" "${A}"; shift ;;
      --block-size=* | --exclude-from=* | --exclude=* | --files0-from=* | --max-depth=* | --threshold=* | --time-style=* | --time=*) pushv DU_ARGS "$1"; shift ;;
      --block-size | --exclude | --exclude-from | --files0-from | --max-depth | --threshold | --time | --time-style) pushv DU_ARGS "$1=$2"; shift 2 ;;
      *) break ;;
    esac
  done
  echo -n > "$TMP"
  trap 'rm -f "$TMP"' EXIT
  CMD='(du -x -s $DU_ARGS -- ${@-$(ls-dirs)})'
  if [ -w "$TMP" ]; then
      CMD="$CMD | (tee \"\$TMP\"; sort -n -k1 <\"\$TMP\" >du.txt; rm -f \"\$TMP\"; echo \"Saved list into du.txt\" 1>&2)"
  fi
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}

each()
{
    __=$1;
    test "`type -t "$__"`" = function && __="$__ \"\$@\"";
    while shift;
    [ "$#" -gt 0 ]; do
        eval "$__";
    done;
    unset __
}

enable-some-swap()
{
    ( SWAPS=` blkid|${GREP-grep} 'TYPE="swap"'|cut -d: -f1 `;
    set -- $SWAPS;
    for SWAP in $SWAPS;
    do
        if swapon "$SWAP"; then
            echo "Enabled swap device $SWAP" 1>&2;
            break;
        fi;
    done )
}

errormsg()
{
    local retcode="${2:-$?}";
    msg "ERROR: $@";
    return "$retcode"
}

error()
{
    local retcode="${2:-1}";
    msg "ERROR: $@";
    if [ "$0" = "-sh" -o "${0##*/}" = "sh" -o "${0##*/}" = "bash" ]; then
        return "$retcode";
    else
        exit "$retcode";
    fi
}

escape-required()
{
    local b="\\" q="\`\$\'\"${IFS}";
    case "$1" in
        '')
            return 1
        ;;
        ["$q"]* | *[!"$b"]["$q"]*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

eval-arith()
{
    eval "echo $(make-arith "$@")"
}



explode_1() {
 (old_IFS="$IFS"; IFS="$1"; shift; set -- $*; IFS="$old_IFS"; echo "$*")
}
explode() {
 [ ${#1} -le 1 -a $# -gt 1 ] && explode_1 "$@" || (S="$1"; shift; IFS="
"; [ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} "s|${S//\"/\\\"}|\n|g")
}

explore () { 
  for ARG in "$@"; do
   (r=`realpath "$ARG" 2>/dev/null`;
    [ "$r" ] || r=$1;
    case "$r" in 
      */*) ;;
      *) r=$PWD/$r ;;
    esac;
    r=${r%/.};
    r=${r#./};
    bs="\\";
    fs="/";
    p=`${PATHTOOL-cygpath} -w "$r"`;
    set -x;
    : ${SYSTEMROOT=$SystemRoot};
     "$SYSTEMROOT/explorer.exe" "/n,/e,${p//$fs/$bs}" );
  done
}

extract-slackpkg()
{
    : ${DESTDIR=unpack};
    mkdir -p "$DESTDIR";
    l=$(${GREP-grep} "$1" pkgs.files );
    pkgs=$(cut -d: -f1 <<<"$l" |sort -fu);
    files=$(cut -d: -f2 <<<"$l" |sort -fu);
    for pkg in $pkgs;
    do
        ( e=$(grep-e-expr $files);
        test -n "$files" && ( set -x;
        tar -C "$DESTDIR" -xvf "$pkg" $files 2> /dev/null ) );
    done
}

extract-version()
{
    echo "$*" | ${SED-sed} 's,^.*\([0-9]\+[-_.][0-9]\+[-_.0-9]\+\).*,\1,'
}

ffcropdetect() {
  ${FFPLAY-ffplay} ${@+-i} ${@+"$@"} -vf cropdetect=24:16:0  -an 2>&1 |grep -iE  '(error|cropdetect)'
}

filesystem-for-device()
{
 (DEV="$1";
  set -- $(${GREP-grep} "^$DEV " /proc/mounts |awkp 3)
  case "$1" in
    fuse*)
      TYPE=$(file -<"$DEV");
      case "$TYPE" in
        *"NTFS "*) set -- ntfs ;;
        *"FAT (32"*) set -- vfat ;;
        *"FAT "*) set -- fat ;;
      esac
    ;;
    "")
      TYPE=$(file -<"$DEV");
      case "$TYPE" in
        *"swap "*) set -- swap ;;
      esac
    ;;
  esac
  echo "$1")
}

filezilla_location()
{ 
    ( IFS="/";
    function add () 
    { 
        O="${O:+$O }$*"
    };
    for PART in $*;
    do
        case "$PART" in 
            "")
                add "1 0"
            ;;
            *)
                add "$(str_length "$PART") $PART"
            ;;
        esac;
    done;
    echo "$O" )
}

filezilla_server() { 
 (. require.sh
  require web/sourceforge
  for ARG in "$@"; do

    URL=$(sourceforge_url "$ARG" download)
    URL=${URL%/}
    HOST=${URL#*://}
    HOST=${HOST%%/*}
    LOCATION=${URL#*$HOST}

    NAME=${URL##*/};
    cat <<EOF
    <Server>
      <Host>${HOST}</Host>
      <Port>21</Port>
      <Protocol>0</Protocol>
      <Type>0</Type>
      <Logontype>0</Logontype>
      <TimezoneOffset>0</TimezoneOffset>
      <PasvMode>MODE_DEFAULT</PasvMode>
      <MaximumMultipleConnections>0</MaximumMultipleConnections>
      <EncodingType>Auto</EncodingType>
      <BypassProxy>0</BypassProxy>
      <Name>${NAME}</Name>
      <Comments />
      <LocalDir />
      <RemoteDir>$(filezilla_location "$LOCATION")</RemoteDir>
      <SyncBrowsing>0</SyncBrowsing>
      <DirectoryComparison>
      0</DirectoryComparison>${NAME}
    </Server>
EOF
  done)
}

filter()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    echo "$LINE";
                    break
                ;;
            esac;
        done;
    done )
}

filter-cmd()
{
    ( IFS="
";
    CMD="$*";
    while read -r LINE; do
        ( case "$CMD" in
            *{}*)
                EXEC=${CMD//"{}"/"$LINE"};
                EVAL="\$EXEC || exit \$?"
            ;;
            *)
                EXEC="$CMD";
                EVAL="\$EXEC \"\$LINE\" || exit \$?"
            ;;
        esac;
        case "$EXEC" in
            *\ *)
                EVAL="$EXEC"
            ;;
            *)

            ;;
        esac;
        eval "$EVAL" ) || break;
    done )
}

filter-filemagic() {
(
 while :; do
   case "$1" in
     -c | --cut) CUT=true; shift ;;
     *) break ;;
   esac
 done
 [ "$CUT" = true ] && EXPR="s,:\\s\\+.*,,p" || EXPR="s,:\\s\\+,: ,p"

  [ $# -gt 0 ]  || set -- ".*"
   for ARG; do
     case "$ARG" in
       "!"*) NOT="!" ARG=${ARG#$NOT} ;;
       *) NOT="" ;;
    esac
     EXPR="\\|:\\s\\+${ARG%%|*}|$NOT { $EXPR }"
   done
  xargs -d "
" file -- | ${SED-sed} -n -u "$EXPR")
}

filter-filesize() {
  (OPS=
  IFS="
"; getnum() {
    N=$1
    case "$N" in
      *[Kk]) N=$(( ${N%[Kk]} * 1024 )) ;;
      *G) N=$(( ${N%G} * 1024 * 1048576)) ;;
      *T) N=$(( ${N%T} * 1048576 * 1048576)) ;;
      *M) N=$(( ${N%M} * 1048576 )) ;;
    esac
    echo "$N"
  }
  while :; do
    case "$1" in
      -gt | -ge | -lt | -le) OPS="${OPS:+$OPS$IFS}\$FILESIZE${IFS}$1${IFS}\$(($(getnum "$2")))"; shift 2 ;;
      -a | -o) OPS="${OPS:+$OPS$IFS}${1}"; shift ;;
      *) break ;;
    esac
  done
  xargs -d '\n' ls -l -d -n --time-style="+%s" -- | {
   set -- $OPS
   IFS=" "
   CMD="test $*"
   while read -r MODE N USERID GROUPID FILESIZE DATETIME PATH; do
     #echo "$FILESIZE" 1>&2
      eval "if $CMD; then echo \"\$PATH\"; fi"

  done; }
  )
}

filter-files-list()
{
    ${SED-sed} "s|/files\.list:|/|"
}

filter-foreach() {
 (IFS="
"
  unset ARGS MODE
  push() {
  eval 'shift; '$1'=${'$1':+"$'$1'$S"}$*'
  }
  S=" -and "
  while :; do
    case "$1" in
      -[0-9]) I=${1#-}; shift ;;
      -eq | -ne | -lt | -le | -gt | -ge)
        push COND "${NEG:+$NEG }\$((N)) $1 $2"
        shift 2
        NEG=""
      ;;
      ">=") push COND "${NEG:+$NEG }\$((N)) -ge $2"; NEG=""; shift ;;
      "<=") push COND "${NEG:+$NEG }\$((N)) -le $2"; NEG=""; shift ;;
      "=="* | "=") push COND "\$((N)) -eq $2"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $2"; NEG=""; shift ;;
      ">") push COND "${NEG:+$NEG }\$((N)) -gt $2"; NEG=""; shift ;;
      "<") push COND "${NEG:+$NEG }\$((N)) -lt $2"; NEG=""; shift ;;

      ">="*) push COND "${NEG:+$NEG }\$((N)) -ge ${1#??}"; NEG=""; shift ;;
      "<="*) push COND "${NEG:+$NEG }\$((N)) -le ${1#??}"; NEG=""; shift ;;
      "=="* | "="*) push COND "\$((N)) -eq ${1#*=}"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne ${1#??}"; NEG=""; shift ;;
      ">"*) push COND "${NEG:+$NEG }\$((N)) -gt ${1#?}"; NEG=""; shift ;;
      "<"*) push COND "${NEG:+$NEG }\$((N)) -lt ${1#?}"; NEG=""; shift ;;

      -o | -or | --or | "||") S=" -o "; shift ;;
      -a | -and | --and | "||") S=" -a "; shift ;;
      '!')
        NEG='! '
        shift ;;
      *) break ;;
    esac
  done
  : ${I:=1}
  CMD=
  for N in $(seq 1 $((I+1))); do
    CMD="${CMD:+$CMD }\${F$N}"
    FIELDS="${FIELDS:+$FIELDS }F$N"
  done
  CMD="echo \"$CMD\""
  CMD="[ $COND ] && $CMD"

  CMD="while read -r $FIELDS; do N=\$F$I; $CMD; done"
  CMD='IFS=" 	"; '$CMD
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}

filter-git-status()
{
 (unset MATCH SUBST MODIFIER
  while :; do
    case "$1" in
      -v) MODIFIER='!'; shift ;;
    *) break ;;
    esac
  done
  WHAT=${1:-untracked}
  shift
  ARGS="-n"
  case "$WHAT" in
    untr*|unkn*) PATTERN='??' ;;
    ign*) PATTERN='!!' ;;
    add*|new*) PATTERN='.\?A' ;;
    modif*|change*) PATTERN='.\?M' ;;
    delete*|remov*) PATTERN='.\?D' ;;
    rena*) PATTERN='.\?R' ;;
    cop[iy]*) PATTERN='.\?C' ;;
    unmerg*|upda*) PATTERN='.\?U' ;;
    #*) echo "No such git status specifier: $WHAT" 1>&2; exit 1 ;;
  esac
  : ${MATCH="\\|^$PATTERN|"}
  : ${SUBST="/\"/ { s,^\(...\)\",\1,; s,\"\$,,; }; s|^...||p"}
  exec ${SED-sed} $ARGS "${MATCH:+$MATCH$MODIFIER} { $SUBST }")
}

filter-num() {
 (IFS=$'\n\t\r '
  unset ARGS MODE
  push() {
  eval 'shift; '$1'=${'$1':+"$'$1'$S"}$*'
  }
  S=" -and "
  while :; do
    case "$1" in
      -[0-9]) I=${1#-}; shift ;;
      -[dt]) SEP=${2}; shift 2 ;; -[dt]=*) SEP=${1#-?=}; shift ;; -[dt]*) SEP=${1#-?}; shift ;;
      -[fk]) I=${2}; shift 2 ;; -[fk]=*) I=${1#-?=}; shift ;; -[fk][0-9]*) I=${1#-?}; shift ;;

      -eq | -ne | -lt | -le | -gt | -ge)
        push COND "${NEG:+$NEG }\$((N)) $1 $(suffix-num "$2")"
        shift 2
        NEG=""
      ;;
      ">=") push COND "${NEG:+$NEG }\$((N)) -ge $(suffix-num "$2")"; NEG=""; shift ;;
      "<=") push COND "${NEG:+$NEG }\$((N)) -le $(suffix-num "$2")"; NEG=""; shift ;;
      "=="* | "=") push COND "\$((N)) -eq $(suffix-num "$2")"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $(suffix-num "$2")"; NEG=""; shift ;;
      ">") push COND "${NEG:+$NEG }\$((N)) -gt $(suffix-num "$2")"; NEG=""; shift ;;
      "<") push COND "${NEG:+$NEG }\$((N)) -lt $(suffix-num "$2")"; NEG=""; shift ;;

      ">="*) push COND "${NEG:+$NEG }\$((N)) -ge $(suffix-num "${1#??}")"; NEG=""; shift ;;
      "<="*) push COND "${NEG:+$NEG }\$((N)) -le $(suffix-num "${1#??}")"; NEG=""; shift ;;
      "=="* | "="*) push COND "\$((N)) -eq $(suffix-num "${1#*=}")"; NEG=""; shift ;;
      "!=") push COND "${NEG:+$NEG }\$((N)) -ne $(suffix-num "${1#??}")"; NEG=""; shift ;;
      ">"*) push COND "${NEG:+$NEG }\$((N)) -gt $(suffix-num "${1#?}")"; NEG=""; shift ;;
      "<"*) push COND "${NEG:+$NEG }\$((N)) -lt $(suffix-num "${1#?}")"; NEG=""; shift ;;

      -o | -or | --or | "||") SEP=" -o "; shift ;;
      -a | -and | --and | "||") SEP=" -a "; shift ;;
      '!')
        NEG='! '
        shift ;;
      *) break ;;
    esac
  done
  : ${SEP=$' \t\r'}
  : ${I:=1}
  CMDX=
  for N in $(seq 1 $((I+1))); do
    CMDX="${CMDX:+$CMDX\$SEP}\${F$N}"
    FIELDS="${FIELDS:+$FIELDS }F$N"
  done
  CMDX="echo \"$CMDX\""
  CMDX="[ $COND ] && $CMDX"

  CMDX="N=\$F$I; $CMDX"

  CMD="while read -r $FIELDS; do [ \"\$DEBUG\" = true ] && echo \"$CMDX\" 1>&2; $CMDX; done"
  CMD="IFS=\"\${SEP-\" 	\"}\"; "$CMD
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "($CMD)")
}

filter-out()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    continue 2
                ;;
            esac;
        done;
        echo "$LINE";
    done )
}

filter-quoted-name()
{
  ${SED-sed} -n "s|.*\`\([^']\+\)'.*|\1|p"
}

filter()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    echo "$LINE";
                    break
                ;;
            esac;
        done;
    done )
}

filter-test() {
 (IFS="
" EXCLAM='! '
  unset ARGS NEG
  while :; do
    case "$1" in
      -X | --debug) DEBUG=true; shift ;;
      -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s | -u | -w | -x)
          ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}$1 \"\$LINE\""; shift; unset NEG ;;
      -E) ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}-f \"\$LINE\" -a ${NEG-$EXCLAM}-s \"\$LINE\""; shift; unset NEG ;;
      -a | -o) ARGS="${ARGS:+$ARGS }$1"; shift; unset NEG ;;
      '!') [ "${NEG-false}" = false ] && NEG="" || unset NEG; shift ;;
      *) break ;;
    esac
  done
#  [ -z "$ARGS" ] && exit 2
#  IFS=" "
#  set -- $ARGS
#  IFS="
#" ARGN=$#; ARGS="$*"
  CMD='while read -r LINE; do
  [ '$ARGS' ] && echo "$LINE"
done'

  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}

find-all() { 

  
  (: ${LOCATE=`cmd-path locate`}
  
   [ -z "$LOCATE" ] && LOCATE=locate32.sh  || LOCATE="$LOCATE
-i
-r"
   
for ARG; do $LOCATE "$ARG"; done ; find-media.sh "$@") |sort -u 
  
  }

findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}

find-homedirs() {
 (locate32.sh /home/ |
  ${SED-sed} 's|/home/\([^/]\+\).*|/home/\1|'|uniq
find-media.sh '/home/[^/]+/$'|removesuffix / ) |
  ${GREP-grep} -vE '(/include/|/usr/)' |
   filter-test -d
}

 find-in-index() {
  (CMD='index-dir -u $DIRS | xargs ${GREP-grep} -E "($EXPRS)" -H | ${SED-sed} "s|/files.list:|/|" -u'
   while :; do
     case "$1" in
       -w | -m) CMD="$CMD | msyspath $1"; shift ;;
       *) break ;;
     esac
    done


  while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushv DIRS "$1"
    else
      EXPRS="${EXPRS:+$EXPRS|}$1"
    fi
    shift
  done
  eval "$CMD"
)
}

findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}

first-char()
{
    echo "${*:0:1}"
}

firstletter()
{
    ( for ARG in "$@";
    do
        REST=${ARG#?};
        echo "${ARG%%$REST}";
    done )
}

fn2re()
{
    echo "$1" | ${SED-sed} -e 's,\.,\\.,g' -e "s,\\?,${2-.},g" -e "s,\\*,${2-.}*,g" -e 's,\[!\([^\]]\+\)\],[^\1],g'
}

for_each() {
  ABORT_COND=' return $?'
  while :; do 
    case "$1" in
      -c | --cd | --ch*dir*) CHANGE_DIR=true; shift ;;
      -f | --force) ABORT_COND=' :'; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  ABORT_COND=' { unset CMD CHANGE_DIR ABORT_COND DEBUG;  [ "$PD" != "$PWD" ] && cd "$PD" >/dev/null; '$ABORT_COND'; }'
  PD=$PWD
  CMD=$1
  if [ "$(type -t "$CMD")" = function ]; then
    CMD="$CMD \"\$@\""
  fi
  [ "$DEBUG" = true ] && CMD="echo \"+\${D:+\$D:} $CMD\" 1>&2; $CMD"
  [ "$CHANGE_DIR" = true ] &&  CMD='D=$1; cd "$D" >/dev/null;'$CMD';cd - >/dev/null'  || CMD='D=;'$CMD
  	
  if [ $# -gt 1 ]; then
    CMD='while shift; [ "$#" -gt 0 ]; do { '$CMD'; } ||'$ABORT_COND'; done'
  else
    CMD='while read -r LINE; do set -- $LINE; { '$CMD'; } ||'$ABORT_COND'; done'
  fi
#	[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD; $ABORT_COND"
}

for-each-char()
{
    x="$1";
    shift;
    s="$*";
    n=${#s};
    i=0;
    while [ "$i" -lt "$n" ]; do
        c=${s:0:1};
        eval "$x";
        s=${s#?};
        i=$((i+1));
    done
}

foreach-mount()
{
    local old_IFS="$IFS";
    {
        IFS="
 ";
        while read -r DEV MNT TYPE OPTS A B; do
            eval "$*";
        done < /proc/mounts
    };
    IFS="$old_IFS"
}

for-each-partition()
{
    ( SCRIPT="$1";
    shift;
    blkid "$@" | while read -r LINE; do
        DEV=${LINE%%": "*};
        VALUES=${LINE#*": "};
        ( eval "$VALUES";
        eval "$SCRIPT" );
    done )
}

foreach-partition() {
    local old_IFS="$IFS";
    blkid | {
        IFS="
 ";
        while read -r DEV VARS; do
            DEV=${DEV%:};
            eval "DEV=\"$DEV\" $VARS";
            eval "$*";
        done
    };
    IFS="$old_IFS"
}

for-each-partition()
{
    ( SCRIPT="$1";
    shift;
    blkid "$@" | while read -r LINE; do
        DEV=${LINE%%": "*};
        VALUES=${LINE#*": "};
        ( eval "$VALUES";
        eval "$SCRIPT" );
    done )
}

fstab-line()
{
    ( while :; do
        case "$1" in
            -u | --uuid) USE_UUID=true; shift ;;
            -l | --label) USE_LABEL=true; shift ;;
            *)
                break
            ;;
        esac;
    done;
    IFS="
 ";
    : ${MNT="/mnt"};
    for DEV in "$@";
    do
        ( unset DEVNAME LABEL MNTDIR #FSTYPE;
        DEVNAME=${DEV##*/};
        LABEL=$(disk-label "$DEV");
        [ -z "$MNTDIR" ] && MNTDIR="$MNT/${LABEL:-$DEVNAME}";
        : ${FSTYPE=$(filesystem-for-device "$DEV")}
        UUID=$(getuuid "$DEV");
        set -- $(proc-mount "$DEV");
        [ -n "$4" ] && : ${OPTS:="$4"};
        [ -n "$5" ] && DUMP="$5";
        [ -n "$6" ] && PASS="$6";
        [ "$USE_UUID" = true -a -n "$UUID" ] && DEV="UUID=$UUID";
        [ "$USE_LABEL" = true -a -n "$LABEL" -a -e /dev/disk/by-label/"$LABEL" ] && DEV="LABEL=$LABEL";
        case "$FSTYPE" in
            swap)
                MNTDIR=none;
                : ${OPTS:=sw}
            ;;
        esac;
        [ -z "$OPTS" ] && OPTS="$DEFOPTS"
        [ -n "$ADDOPTS" ] && OPTS="${OPTS:+$OPTS,}$ADDOPTS"


        [ "${FSTYPE}" = fuseblk ] && unset FSTYPE

        OPTS=${OPTS//,relatime/,noatime}
        OPTS=${OPTS//,blksize=[0-9]*/}
        OPTS=${OPTS//,errors=remount-ro/}
        OPTS=${OPTS//,user_id=0/,user_id=${USER_ID:-0}}
        OPTS=${OPTS//,uid=0/,uid=${USER_ID:-0}}
        OPTS=${OPTS//,group_id=0/,group_id=${GROUP_ID:-0}}
        OPTS=${OPTS//,gid=0/,gid=${GROUP_ID:-0}}
        printf "%-40s %-24s %-6s %-6s %6d %6d\n" "$DEV" "$MNTDIR" "${FSTYPE:-auto}" "${OPTS:-auto}" "${DUMP:-0}" "${PASS:-0}" );
    done )
}

fstentry()
{
    ( DEV="$1" TYPE=${2-auto} OPTS=${3-defaults};
    MNT=/media/${DEV##*/};
    blkvars "$DEV";
    echo -e "UUID=$UUID\t$MNT\t\t$TYPE\t$OPTS\t0 0" )
}

gcd()
{
    ( A="$1" B="$2";
    while :; do
        if [ "$A" = 0 ]; then
            echo "$B" && break;
        fi;
        B=$((B % A));
        if [ "$B" = 0 ]; then
            echo "$A" && break;
        fi;
        A=$((A % B));
    done )
}

gen-desktop()
{ 
    cat  > "$(basename "$1")".desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=${1##*/}
GenericName=${1##*/}
Comment=
Icon=${1##*/}
Type=Application
Categories=Application;
Exec=$1
Terminal=false
Path=
StartupNotify=true

EOF

}

gen-move-ebooks()
{ 
    for F in "$@";
    do
        BASEDIR=$(echo "$F"|sed "s|\(.*Books[^/]*\)/.*|\1|i ; s|\(.*Calibre[^/]*\)/.*|\1|i");
        RELPATH=${F#$BASEDIR/};
        echo "mkdir -p 'G:/Books/${RELPATH%/*}'; mv -vf '$F' 'G:/Books/${RELPATH%/*}'";
    done
}

get-bpm() {
  while :; do
    case "$1" in
      -i | --int*) INTEGER=true; shift ;;
      *) break ;;
    esac
  done
  [ $# -gt 1 ] && PFX="\$1: " || PFX=
  [ "$INTEGER" = true ] && DOT= || DOT="."
    CMD="${SED-sed} -n \"/TBPM/ { s|.*TBPM\\x00\\x00\\x00\\x07\\x00*|| ;; s,[^${DOT}0-9].*,, ;; s|^|$PFX| ;;  p }\" \"\$1\""
  while [ $# -gt 0 ]; do
    #echo "+ $CMD" 1>&2
    eval "$CMD"
    shift
  done
}

get-chrome()
{ 
    cygpath -a "$(ps -aW|sed 's,\\,/,g'|grep -i 'chrome[^/]*exe$' |sed 's|.* \(.\):\(.*\)|\1:\2|' | head -n1)"
}

get-dotfiles()
{
    ( UA="curl/7.25.0 (x86_64-suse-linux-gnu) libcurl/7.25.0 OpenSSL/1.0.1c zlib/1.2.7 libidn/1.25 libssh2/1.4.0";
    list-dotfiles "$@" | while read -r URL; do
        NAME=${URL##*/};
        USER=${URL%"/$NAME"};
        USER=${USER##*/};
        USER=${USER#"~"};
        ( set -x;
        wget -U "$UA" -O "${NAME#.}-$USER" "$URL" );
    done )
}

get-eagle-file()
{ 
    tasklist /fi "IMAGENAME eq eagle*" /v /fo list 2>&1 | sed -n 's,\\,/,g; s,\r*$,,; /Window Title:/ s,.* - \(.*\) - EAGLE.*,\1,p'
}

get-ebooks()
{ 
    export DATABASE=$(cygpath -am "$USERPROFILE/AppData/Roaming/Locate32/files.dbs");
    ls $LS_ARGS -td -- $( (locate32.sh  -E{pdf,epub,mobi,azw3,djv,djvu}|grep -i -E '(books|calibre)'; find-media.sh  -E{pdf,epub,mobi,azw3,djv,djvu} calibre books) |sort -f -u )
}

get-exports() {
 (N=$#
  [ "$N" -gt 1 ] && PREFIX='$ARG: ' || PREFIX=''
  CMD='dumpbin -exports "$ARG" |${SED-sed} -n "/^\\s*ordinal\\s\\+name/ { n; :lp; n; s|^\\s*[0-9]*\\s\\+\\(.*\\)|'$PREFIX'\\1|p; /^\\s*\$/! b lp; }"'
  for ARG; do
    eval "$CMD"
  done)
}

get-ext()
{
    set -- $( ( (set -- $(${GREP-grep} EXT.*= {find,locate,grep}-$1.sh -h 2>/dev/null |${SED-sed} "s,EXTS=[\"']\?\(.*\)[\"']\?,\1," ); IFS="$nl"; echo "$*")|${SED-sed} 's,[^[:alnum:]]\+,\n,g; s,^\s*,, ; s,\s*$,,';) |sort -fu);
    ( IFS=" ";
    echo "$*" )
}

get-firefox()
{ 
    cygpath -a "$(ps -aW|sed 's,\\,/,g'|grep -i '/firefox[^/]*exe$' |sed 's|.* \(.\):\(.*\)|\1:\2|' | head -n1)"
}

get-frags() {
 (while :; do
    case "$1" in
      -l | --left) LEFT=true; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  FS="/" BS="\\"
  EXPR="s/.*Average frag.*:\s\+\([0-9]\+\)\s\+.*/\1/"
  if [ $# -gt 1 ]; then
    "${LEFT:-false}" &&
    EXPR="$EXPR ;; s/\$/${SEP:- }\${ARG//\$FS/\$BS\$FS}/" ||
    EXPR="$EXPR ;; s/^/\${ARG//\$FS/\$BS\$FS}${SEP:-: }/"
  fi
  EXPR="/Average frag/ { $EXPR; p }"
  CMD='contig -a "$ARG" | ${SED-sed} -n "'$EXPR'"'
  CMD="($CMD) || return \$?"
  "${DEBUG:-false}" && echo 1>&2 "CMD='$CMD'"
  eval "for ARG; do
   $CMD
  done")
}

get-installed()
{ 
    ( ( set /etc/setup/*.lst*;
    set -- "${@##*/}";
    set -- "${@%.lst*}";
    echo "$*";
    awkp < /etc/setup/installed.db ) | sort -u )
}

get-lotto() {
    dl-lotto() {
		eval "set -- http://www.mylottoy.net/de/lotto-schweiz/lottozahlen/6aus45/lottozahlen-{`Y=$(date +%Y); seq -s, $((Y)) -1 $((Y-5))`}.asp"
		
			for_each -f -x 'lynx -source "$1"' "$@"
		}
    CMD='dl-lotto'
    if [ -n "$1" -a -e "$1" ]; then
      CMD='cat "$@"'
    fi
    eval "$CMD" | sed "s|<div class='span-30'>|\n&|gp" | grep --color=auto --line-buffered --text span-30 | \
    sed -n '/ den / { s,<[^>]*>,;,g ; s,([^)]*),,g ; s,\&nbsp;, ,g; s,;\s\+,;,g; s,\s\+:\s\+,:,g; s,;\+,;,g; s,:;,: ,g ; s,^;,, ; s,;$,, ;  s|\([[:upper:]][[:lower:]]\)[a-z]* den |\1, | ; p }'  |
    sed 's,\([0-9]\):\([0-9]\),\1 \2,g ; s,\([0-9]\):\([0-9]\),\1 \2,g ; s|;\([0-9]\) |; \1 | ;
    s,\([0-9]\) \([0-9]\) ,\1  \2 ,g ; s,\([0-9]\) \([0-9]\) ,\1  \2 ,g' |
    sed 's,: \([0-9]\)\([; ]\),:  \1\2,g' |
    sed 's,Replay:\s\+\([0-9]\)$,Replay:  \1,' |
    sed 's,\([A-Za-z]\+:\s\+[0-9]\+\);\([A-Za-z]\+:\s\+[0-9]\+\),\1 \2,g ; s,\([A-Za-z]\+:\s\+[0-9]\+\);\([A-Za-z]\+:\s\+[0-9]\+\),\1 \2,g' |
    sed 's|;|\t|g' |
    sed 's|\(..............\)\s\(.................\)\s\(......\)\s\(........\)|\1\t\2\t\3\t\4|'
}

get-mingw-properties() {
 (unset PROPS
  : ${OUTCMD="var-get"}
  while [ $# -gt 0 ]; do
   case "$1" in
     -x | --debug) OUTCMD="var_dump"; DEBUG=true; shift ;;
     *[-/\\.]*) break ;;
     --) shift; break ;;
     *) IFS="
 " pushv PROPS "$1"; shift ;;
   esac
 done
 if [ -z "$PROPS" ]; then
   IFS="
" pushv PROPS EXE ARCH BITS DATE THREADS EXCEPTIONS VER TARGET #PROPS ARCH BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER XBITS SUBDIR EXE VERN DRIVE VERSTR VERNUM TOOLCHAIN TARGET
 fi
 [ "$DEBUG" = true ] && echo "PROPS:" $PROPS 1>&2
 for ARG; do
   [ "$ARG" = -- ] && continue
  ([ "$DEBUG" = true ] && echo "ARG: $ARG" 1>&2
   NOVER=${ARG%%-[0-9]*}; VER=${ARG#"$NOVER"}; VER=${VER#[!0-9]}
   S_IFS="$IFS"
   IFS="${IFS:+-$IFS}/\\"
   unset BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER VERNUM VERSTR XBITS
   set -- $ARG
   IFS="$S_IFS"
   while [ $# -gt 0 ]; do
   #[ "$DEBUG" = true ] && echo "+ $1 $2" 1>&2
     case "$1" in
       *snapshot*) SNAPSHOT=$2; IFS="-" pushv VERNUM "snapshot$2"; shift; pushv VERSTR "snapshot$2" ;;
       rev?????? |rev????????) DATE="${1#rev}" ; pushv VERSTR "d$DATE" ;;
       rev*) REV="${1#rev}" ; pushv VERSTR "r$REV" ;;
       rt_v*) RTVER="${1#rt_v}"; pushv  VERSTR "rt$RTVER" ;;
       x86_64|x64|mingw64|amd64) BITS=64 ARCH=x86_64 MACH=x64 XBITS=x64 ;;
       i?86|x32|x86) BITS=32 ARCH=i686 MACH=x86 XBITS=x32 ;;
       seh) EXCEPTIONS=seh ;;
       sjlj) EXCEPTIONS=sjlj ;;
       posix) THREADS=posix ;;
       win32|w32) THREADS=win32 ;;
       dwarf|dw2) EXCEPTIONS=dw2 ;;
       #[0-9].[0-9]* |   [0-9]*) VERNUM="$1"; pushv VERSTR "$VERNUM" ;;
       ???drive) DRIVE="$2"; shift  ;;
       ?:) DRIVE="${1%:}" ;;
       w64) MINGWTYPE=mingw-w64 ;;
       mingwbuilds) MINGWTYPE=$1 ;;
       cc | gcc | g++ | gxx) ;;
       cygwin | msys) MINGWTYPE=$1-cross ;;
       mingw32 | mingw64) MINGWBITS=$1 ;;
       mingw[[:digit:]]*) MINGWVER=${1#mingw}; : pushv VERNUM "${1}" ;;
       [Bb]in | [Ll]ib | [Ii]nclude) SUBDIR="$1" ;;
       [[:digit:]]*) VERN="$1"; pushv VERNUM "$1" ;;
       *.EXE | *.exe) EXE="${1}" ;;
       # *) IFS="-" pushv VERNUM "$1";  pushv VERSTR "$1" ;;
       "") ;;
       *) IFS="-" pushv VERNUM "$1";  pushv VERSTR "$1" ; [ "$DEBUG" = true ] && echo "No such version str: '$1'" 1>&2 ;;
      esac
      shift
    done
   VERNUM=${VERNUM#[!0-9a-z]}; VERNUM=${VERNUM#mingw}; VERNUM=${VERNUM#[![:alnum:]]}

    S_IFS="$IFS"; IFS="$IFS :-
"; set -- $VERNUM; IFS="$S_IFS"

  while [ -z "$1" -o "${1}" = mingw -a $# -gt 0 ]; do shift ; done

  case "$VERNUM" in
    [0-9]*.*) MINGWVER=${VERNUM//"."/} ;;
    [0-9]*) MINGWVER=${VERNUM} ;;
  esac
	 [ -z "$MINGW" -a -n "$MINGWVER" ] && MINGW="mingw${MINGWVER#mingw}"
	 if [ -z "$MINGW" ] ; then
		 set -- "${@#mingw}"
		 case "$*" in
				[[:xdigit:]]*) MINGW="mingw${1//./}" ;;
				*) #[ -n "$VERNUM" ] && MINGW=mingw"${VERNUM#mingw}"
			 ;;
		 esac
	 fi
	 #[ -n "$MINGWVER" ] && MINGW="mingw${MINGWVER}"
		W64ID="${ARCH}-${1}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}${RTVER:+-rt_v$RTVER}${REV:+-rev$REV}"
		BUILDSID="${XBITS}-${1}${SNAPSHOT:+-snapshot-$SNAPSHOT}${DATE:+-rev$DATE}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}"
		if [ "$MINGWTYPE" = mingw-w64 ]; then
			TOOLCHAIN=${W64ID}
		elif [ "$MINGWTYPE" = mingwbuilds ]; then
			TOOLCHAIN=${BUILDSID}
		fi
		TARGET="${ARCH}-${MINGW:-mingw${1//./}${RTVER:+-rt$RTVER}}${REV:+r$REV}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}"
		VER="${1}${REV:+r$REV}${DATE:+d$DATE}${RTVER:+-rt$RTVER}"
		shift
		VER="$VER${*:+-$*}"
		#set VERSTR="$VERSTR"
		#echo "ARCH='$ARCH'${BITS:+ BITS='$BITS'}${DATE:+ DATE='$DATE'}${EXCEPTIONS:+ EXCEPTIONS='$EXCEPTIONS'}${MACH:+ MACH='$MACH'}${REV:+ REV='$REV'}${RTVER:+ RTVER='$RTVER'}${SNAPSHOT:+ SNAPSHOT='$SNAPSHOT'}${THREADS:+ THREADS='$THREADS'}${VER:+ VER='$VER'}${XBITS:+ XBITS='$XBITS'}"
		var_s=" "  $OUTCMD ${PROPS})
  done)
}

get-prefix()
{ 
    ${CC:-gcc} -print-search-dirs |sed -n 's,.*:\s\+=\?,,; s,/\+,/,g; s,/bin.*,,p ; s,/lib.*,,p ' |head -n1
}

get-property()
{
    ${SED-sed} -n "/$1=/ {
   s,.*$1=,,
   /\"/! { s,\s\+.*,, }
   /^\".*\"/ { s,^\([^\"]\+\)\".*\".*,\\1, ; s,^\",, ; s,\".*,, }

  p
}"
}

get-rootfs() {
  ${SED-sed} -n 's,.*root=\([^ ]\+\).*,\1,p' /proc/cmdline
}

get-shortcut()
{
  (for SHORTCUT; do
  (    set -- TARGET=-t WDIR=-g ARGS=-r ICON=-i ICONOFFSET=-j DESC=-d SHOWCMD=-s
  O=
   for A; do
     O="${O:+$O
}${A%%=*}=$(readshortcut ${A##*=} "$SHORTCUT")"
     done
     echo "$O")
     done)
}

getuuid()
{
    blkid "$@" | ${SED-sed} -n "/ UUID=/ { s,.* UUID=\"\?,, ;; s,\".*,, ;; p }"
}

get-volume-list() {
 (

 set -- $(df -l | sed '1d; s|\s\+.*||;  \|^/dev|! { \|^.:|! d }; /^.:/ s|[/\\].*||')
 while [ $# -gt 0 ]; do
     
     
     echo "$1" $(volname "$1")
     shift
 done

 
# set -- $(df -hl|sed -n '\|^/dev/.d| { s,\s.*,, ; s|.*/||; p }'|grep-e-expr)
#  ls -la -d -n --time-style=+%s -- /dev/disk/by-label/* | grep -E "/$(IFS="|"; echo "$*")\$" |
#  { IFS=" "; while read -r MODE N USR GRP SIZE TIME LABEL _A DEVICE; do echo "/dev/${DEVICE##*/}" "${LABEL##*/}"; done; }

)
}


 

get-volume-path() {
  (
  get-volume-list |sed "\\|\s${1}\$| { s|\s${1}\$||; \\|/|! { s|\$|/| }; p }" -n 
#  RF="[^ ]\+\s\+"
#  for ARG; do
#  df "$(  get-volume-list |sed -n "\\|\\s$ARG\$| { s|\s.*||; p }")" |sed "1d; s|^${RF}${RF}${RF}${RF}${RF}||"
#
#
#   done
)
}

git-branches()
{
 (EXPR='\, -> ,d ;; s,^remotes/,,'
  while :; do
    case "$1" in
      -l | --local) EXPR="\\,^remotes/,d ;; $EXPR"; shift ;;
      -r | --remote) EXPR="\\,^remotes/,!d ;; $EXPR"; shift ;;
      *) break ;;
    esac
  done
  EXPR="s,^. ,, ;; $EXPR"
  git branch -a | ${SED-sed} "$EXPR"
 )
}

git-deep-checkout() {
  (for BRANCH in $(git-branches -r "$@"); do
    git branch --track "${BRANCH##*/}" "$BRANCH"
   done)
}

git-get-branch() {
  git branch -a |${SED-sed} -n 's,^\* ,,p'
}

git-get-remote() {
 (unset NAME
  while :; do
 		case "$1" in
      -l | --list) LIST=true; shift ;;
      -n | --name) NAME=$2; shift 2 ;; -n=* | --name=*) NAME=${1#*=}; shift ;;
      *) break ;;
    esac
  done
  [ $# -lt 1 ] && set -- .
  [ $# -ge 1 ] && FILTER="${SED-sed} \"s|^|\$DIR: |\"" || FILTER=

  EXPR="s|\\s\\+| |g"
  if [ -n "$NAME" ]; then
    EXPR="$EXPR ;; \\|^$NAME\s|!d"
  fi
  if [ "$LIST" = true ]; then
    EXPR="$EXPR ;; s| .*||"
  else
    EXPR="$EXPR ;; s|\\s*([^)]*)||"
  fi
  CMD="REMOTE=\`git remote -v 2>/dev/null"
  CMD="$CMD | ${SED-sed} \"$EXPR\""
  CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;"
  CMD=$CMD'echo "$REMOTE"'
  for DIR; do
          (cd "${DIR%/.git}" >/dev/null &&	eval "$CMD")
    done)

}

git-remove-from-history()
{ 
    git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch '$1'"
}

git-restore-deleted() {
  git log --diff-filter=D --summary |
  while read -r LINE; do
    case "$LINE" in
        commit\ *) COMMIT=${LINE#* } ;;
        *delete\ mode\ *) 
            MODE=${LINE#*"delete mode "}
            FILE=${MODE#*" "}
            MODE=${MODE%%" "*}
        ;;
        *) MODE= FILE= ;;
    esac
    if [ -n "$FILE" ]; then
        echo "git checkout $COMMIT~1 -- $(quote "$FILE")"
    fi
  done
}

git-set-remote()
{
  ( IFS="
"
  while :; do
    case "$1" in
      -f | --force) FORCE=true; shift ;;
      *) break ;;
    esac
  done

  gsr-arg() {
   (unset DIR NAME REMOTE
    ARG="$*"
    case "$ARG" in
      *:\ *) DIR=${ARG%%": "*}; ARG=${ARG#"$DIR: "} ;;
    esac
    if [ -n "$DIR" -a -d "$DIR" ]; then
      eval "${PRECMD}cd \"\$DIR\""
    fi
    case "$ARG" in
      *\ * | *$IFS*) NAME="${ARG%%[ $IFS]*}"; REMOTE="${ARG#*[ $IFS]}" ;;
      *) NAME="$ARG";  shift ;;
    esac
      [ -n "$DIR" ] && echo "Setting git remote '$NAME' in '$DIR' to '$REMOTE'" 1>&2

     eval "${PRECMD}git remote rm \"\$NAME\"" #2>/dev/null
     true

     if [ -n "$REMOTE" ]; then
       eval "${PRECMD}git remote add \"\$NAME\" \"\$REMOTE\""
     fi
   )
     #   for NAME in $(git-get-remote | awkp ); do :; done

  }
  CMD='gsr-arg $R'
  CMD="$CMD; R=\$?; [ \"\$FORCE\" = true -o \"\$R\" = 0 ] || exit \$R"

  if [ $# -le 0 ]; then
    CMD='while read -r R; do '$CMD'; done'
  else
    CMD='while [ $# -gt 0 ]; do
      case "$1|$2|$3" in
        *": "*\|*": "*\|*": "*) R="$1"; S=1 ;;
        *": "*\|?*\|*": "*) R="$1 $2"; S=2 ;;
        *": "*\|?*\|?*)   R="$1 $2 $3"; S=3 ;;
        ?*\|?*\|*)   R="$1 $2"; S=2 ;;
        *\|*\|*)   R="$1"; S=2 ;;
      esac
      '$CMD'
      echo "Shifting by $S" 1>&2
      [ "$S" -gt "$#" ]  && S=$#
      shift ${S:-1}
      unset S
    done'
  fi
  eval "$CMD")
}

grep-e()
{
    (IFS="
";  unset ARGS;
    eval "LAST=\"\${$#}\"";
    if [ ! -d "$LAST" ]; then
        unset LAST;
    else
        A="$*"; A="${A%$LAST}";
        set -- $A;
    fi;
    while [ $# -gt 0 ]; do
        case "$1" in
            --) shift; LAST="$*"; break ;;
            -*) ARGS="${ARGS+$ARGS$IFS}$1"; shift ;;
            *) WORDS="${WORDS+$WORDS$IFS}$1"; shift ;;
        esac;
    done;
    ${GREP-grep} -E $ARGS "$(grep-e-expr $WORDS)" ${LAST:+$LAST} )
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
grep-e-expr()
{
  [ $# -gt 0 ] && exec <<<"$*"

  sed 's,[().*?|\\+],\\&,g ; s,\[,\\[,g ; s,\],\\],g' | implode "|" | sed 's,.*,(&),'
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
grephexnums()
{
    ( IFS="|";
    unset ARGS;
    while :; do
        case "$1" in
            -*)
                ARGS="${ARGS+$ARGS$IFS}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    set -x;
    ${GREP-grep} -E $ARGS "(${*#0x})" )
}

<<<<<<< HEAD
=======
=======
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
 grep-in-index() {
  (CMD='index-dir -u $DIRS | xargs ${GREP-grep} "[^/]\$" -H | ${SED-sed} "s|^$PWD/files.list:|| ; s|/files.list:|/|" -u | xargs ${GREP-grep
-a
--line-buffered
--color=auto} $OPTS -H -E "($EXPRS)" '
#   case "$PATHTOOL" in
#     cygpath*) PATHTOOL="xargs $PATHTOOL" ;;
#   esac
   while :; do
     case "$1" in
#       -w | -m) CMD="$CMD | ${PATHTOOL:-xargs cygpath} $1"; shift ;;
       -A|-B|-C|-D|-E|-F|-G|-H|-I|-L|-NUM|-P|-R|-T|-U|-V|-Z|-a|-b|-c|-d|-e|-f|-h|-i|-l|-m|-n|-o|-q|-r|-s|-u|-v|-w|-x|-z|\
       --color|--basic-regexp|--binary|--byte-offset|--count|--dereference-recursive|--extended-regexp|--files-with-matches|--files-without-match|--fixed-strings|--help|--ignore-case|--initial-tab|--invert-match|--line-buffered|--line-number|--line-regexp|--no-filename|--no-messages|--null|--null-data|--only-matching|--perl-regexp|--quiet|--recursive|--silent|--text|--unix-byte-offsets|--version|--with-filename|--word-regexp) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
       --*=*) OPTS="${OPTS:+$OPTS
}$1
$2"; shift 2 ;;
       *) break ;;
     esac
    done


  while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushv DIRS "$1"
    else
      EXPRS="${EXPRS:+$EXPRS|}$1"
    fi
    shift
  done
  eval "$CMD"
)
}

grep-v-optpkgs()
{
    ${GREP-grep} -v -E '\-(doc|dev|dbg|extra|lite|prof|extra|manual|data|examples|source|theme|manual|demo|help|artwork|contrib|svn$|bzr$|hg$|git$|cvs$)'
}

grep-v-unneeded-pkgs()
{
 (set -- common data debuginfo devel doc docs el examples fonts javadoc plugin static theme tests extras demo manual test  \
	 help info support demos bzr svn git hg

 ${GREP-grep} -v -E "\-$(grep-e-expr "$@")(\$|\\s)")
}

grub2-device-string()
{
    ( device_number=` disk-device-number "$1" `;
    partition_number=` disk-partition-number "$1" `;
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}

grub2-menuentry()
{
    ( NAME="$1";
    : ${INDENT="  "};
    shift;
    echo "menuentry '$NAME' {";
    IFS=" ";
    IFS="$IFS
";
    ENTRY="$*";
    unset LINE;
    function output-line()
    {
        [ "$LINE" ] && echo "$INDENT"$LINE;
        unset LINE
    };
    for WORD in $ENTRY;
    do
        case $WORD in
            acpi | chainloader | configfile | drivemap | echo | export | initrd | insmod | kernel | linux | linux16 | loadfont | menuentry | password | play | removed | search | set | source | submenu | timeout)
                output-line
            ;;
        esac;
        LINE="${LINE+$LINE
}$WORD";
    done;
    output-line;
    echo "}" )
}

grub2-modules-for-device()
{
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    FS=$(filesystem-for-device "$ARG");
    SUFFIX=${1##*/};
    SUFFIX=${SUFFIX#[hs]d[a-z]};
    DISK=${1%"$SUFFIX"};
    [ "$DISK" ] && PART_TYPE=$(partition-table-type "$DISK");
    case "$PART_TYPE" in
        msdos | mbr*)
            echo "${2}insmod part_msdos"
        ;;
        gpt* | guid*)
            echo "${2}insmod gpt"
        ;;
    esac;
    case "$FS" in
        ntfs)
            echo "${2}insmod ntfs"
        ;;
        vfat | fat32)
            echo "${2}insmod vfat"
        ;;
        fat | fat16)
            echo "${2}insmod fat"
        ;;
        hfsplus | hfs+)
            echo "${2}insmod hfsplus"
        ;;
        ext[0-9])
            echo "${2}insmod ext2"
        ;;
    esac )
}

grub2-root-for-device()
{
    ( [ ! -b "$1" ] && exit 2;
    ROOT=$(grub2-device-string "$1");
    echo "set root='$ROOT'" )
}

grub2-search-for-device()
{
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    BLKID=$(blkid "$ARG");
    eval "${BLKID#*": "}";
    echo "${2}search --no-floppy --fs-uuid --set" $UUID )
}

grub-device-string()
{
    ( 
    
   grubdisk=$(lookup-grub-devicemap "$1")    
   if [ -n "$grubdisk" ]; then
	  device_number=${grubdisk#?hd}
	  device_number=${device_number%")"}
	else
    device_number=` disk-device-number "$1" `;
    fi
    
    
    
    partition_number=` disk-partition-number "$1" `;
    [ "$partition_number" ] && partition_number=$((partition_number-1));
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}

hex2bin() {
 (
  for N ; do
    
    echo "binary scan [binary format H* \"${N#0x}\"] B* b
puts \$b"
  done) | tclsh| addprefix "${P-0b}"
}

hex2chr()
{
    echo "puts -nonewline [format \"%c\" 0x$1]" | tclsh
}

hex2dec() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$(($N))" ;;
    esac
    echo "obase=10;$N" | bc -l
  done | addprefix "${P-}")
}

hexdump-printfable()
{
    . require str;
    hexdump -C -v < "$1" | ${SED-sed} "s,^\([0-9a-f]\+\)\s\+\(.*\),\2 #0x\1, ; #s,0x0000,0x," | ${SED-sed} "s,|[^|]*|,, ; s,^, ," | ${SED-sed} "s,\s\+\([0-9a-f][0-9a-f]\), 0x\\1,g" | ${SED-sed} "s,^,printf \"$(str_repeat 16 %c)\\\n\" ,"
}

hexnums-dash()
{
    ${SED-sed} "s,[0-9A-Fa-f][0-9A-Fa-f],&-\\\\?,g"
}

hexnums-to-bin()
{
    ( require str;
    unset NL;
    case $1 in
        -l)
            shift;
            NL="
"
        ;;
    esac;
    IFS=" ";
    OUT=` echo "puts -nonewline \"[format $(str_repeat $#  %c) $* ]\""|tclsh `;
    echo -n "$OUT$NL" )
}

hex-to-bin()
{
    local chars=`str_to_list "$1"`;
    local bin IFS="$newline" ch;
    for ch in $chars;
    do
        case $ch in
            0)
                bin="${bin}0000"
            ;;
            1)
                bin="${bin}0001"
            ;;
            2)
                bin="${bin}0010"
            ;;
            3)
                bin="${bin}0011"
            ;;
            4)
                bin="${bin}0100"
            ;;
            5)
                bin="${bin}0101"
            ;;
            6)
                bin="${bin}0110"
            ;;
            7)
                bin="${bin}0111"
            ;;
            8)
                bin="${bin}1000"
            ;;
            9)
                bin="${bin}1001"
            ;;
            a | A)
                bin="${bin}1010"
            ;;
            b | B)
                bin="${bin}1011"
            ;;
            c | C)
                bin="${bin}1100"
            ;;
            d | D)
                bin="${bin}1101"
            ;;
            e | E)
                bin="${bin}1110"
            ;;
            f | F)
                bin="${bin}1111"
            ;;
        esac;
    done;
    echo "$bin"
}

hex-to-dec()
{
    eval 'echo $((0x'${1%% *}'))'
}

hsl()
{
    ( h=$(( $1 * 360 / 255 ));
    s=$2 l=$3;
    while [ "$h" -lt 0 ]; do
        h=$((h+360));
    done;
    while [ "$h" -gt 360 ]; do
        h=$((h-360));
    done;
    if [ "$h" -lt 120 ]; then
        rsat=$(( (120-h) ));
        gsat=$(( h ));
        bsat=$(( 0 ));
    else
        if [ "$h" -lt 240 ]; then
            rsat=$(( 0 ));
            gsat=$(( (240-h) ));
            bsat=$(( (h-120) ));
        else
            rsat=$(( (h-240) ));
            gsat=$(( 0 ));
            bsat=$(( (360-h) ));
        fi;
    fi;
    rsat=$(min $rsat 60);
    gsat=$(min $gsat 60);
    bsat=$(min $bsat 60);
    echo $rsat $gsat $bsat;
    rtmp=$(( 2*${s}*${rsat}+(255-s) ));
    gtmp=$(( 2*${s}*${gsat}+(255-s) ));
    btmp=$(( 2*${s}*${bsat}+(255-s) ));
    echo $rtmp $gtmp $btmp;
    if [ "$l" -lt 255 ]; then
        r=$(( l*rtmp/65535 ));
        g=$(( l*gtmp/65535 ));
        b=$(( l*btmp/65535 ));
    else
        r=$(( ((255-l)*rtmp+2*l)/65535 ));
        g=$(( ((255-l)*gtmp+2*l-255)/65535 ));
        b=$(( ((255-l)*btmp+2*l-255)/65535 ));
    fi;
    echo $r $g $b )
}

http-head()
{
    ( HOST=${1%%:*};
    PORT=80;
    TIMEOUT=30;
    if [ "$HOST" != "$1" ]; then
        PORT=${1#$HOST:};
    fi;
    if type curl > /dev/null 2> /dev/null; then
        curl -q --head "http://$HOST:$PORT$2";
    else
        if type lynx > /dev/null 2> /dev/null; then
            lynx -head -source "http://$HOST:$PORT$2";
        else
            {
                echo -e "HEAD ${2} HTTP/1.1\r\nHost: ${1}\r\nConnection: close\r\n\r";
                sleep $TIMEOUT
            } | nc $HOST $PORT | ${SED-sed} "s/\r//g";
        fi;
    fi )
}

icacls-r() {
 (while :; do
    case "$1" in
      -u | --user) NTUSER="$2"; shift 2 ;;  -u=* | --user=*) NTUSER=${1#*=}; shift ;; -u*) NTUSER=${1#-?}; shift ;;
      -e | --everyone) NTUSER="Everyone"; shift ;;
      -r | --reset) RESET="true"; shift ;;
      -f | --full) FULL="true"; shift ;;
      -o | --own*) TAKEOWN="true"; shift ;;
      -c | --cmd) CMD="true"; shift ;;
      -p | --print) PRINT="true"; shift ;;
      -s | --separator) SEP="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  if [ "$CMD" = true ]; then
    : ${SEP=" & "}
    NUL="nul"
  fi
  : ${ICACLS=icacls}
  
  if [ "$FULL" ]; then
    PERM="F"
  else
	PERM="(OI)(CI)M"
  fi
	
  #DEFAULT_USER="*S-1-0"          # Null Authority
  #DEFAULT_USER="*S-1-0-0"        # Nobody
  #DEFAULT_USER="*S-1-1"          # World Authority
  #DEFAULT_USER="*S-1-1-0"        # Everyone
  #DEFAULT_USER="*S-1-2"          # Local Authority
  #DEFAULT_USER="*S-1-3"          # Creator Authority
  DEFAULT_USER="*S-1-3-0"        # Creator Owner
  #DEFAULT_USER="*S-1-3-1"        # Creator Group
  #DEFAULT_USER="*S-1-3-2"        # Creator Owner Server
  #DEFAULT_USER="*S-1-3-3"        # Creator Group Server
  #DEFAULT_USER="*S-1-4"          # Nonunique Authority
  #DEFAULT_USER="*S-1-5"          # NT Authority
  #DEFAULT_USER="*S-1-5-1"        # Dialup
  #DEFAULT_USER="*S-1-5-2"        # Network
  #DEFAULT_USER="*S-1-5-3"        # Batch
  #DEFAULT_USER="*S-1-5-4"        # Interactive
  #DEFAULT_USER="*S-1-5-6"        # Service
  #DEFAULT_USER="*S-1-5-7"        # Anonymous
  #DEFAULT_USER="*S-1-5-8"        # Proxy
  #DEFAULT_USER="*S-1-5-9"        # Enterprise Controllers
  #DEFAULT_USER="*S-1-5-10"       # Principal Self (or Self)
  #DEFAULT_USER="*S-1-5-11"       # Authenticated Users
  #DEFAULT_USER="*S-1-5-12"       # Restricted Code
  #DEFAULT_USER="*S-1-5-13"       # Terminal Server Users
  #DEFAULT_USER="*S-1-5-18"       # Local System
  #DEFAULT_USER="*S-1-5-32-544"   # Administrators
  #DEFAULT_USER="*S-1-5-32-545"   # Users
  #DEFAULT_USER="*S-1-5-32-546"   # Guests
  #DEFAULT_USER="*S-1-5-32-547"   # Power Users
  #DEFAULT_USER="*S-1-5-32-548"   # Account Operators
  #DEFAULT_USER="*S-1-5-32-549"   # Server Operators
  #DEFAULT_USER="*S-1-5-32-550"   # Print Operators
  #DEFAULT_USER="*S-1-5-32-551"   # Backup Operators
  #DEFAULT_USER="*S-1-5-32-552"   # Replicators

  GRANT="${NTUSER-$DEFAULT_USER}:$PERM"
  
  if [ "$RESET" = true ]; then
    COMMAND="/RESET"
  else
    COMMAND="/grant \"$GRANT\""
  fi
  
  case "$ICACLS" in
    *icacls*) ICACLS_ARGS="/inheritance:e /T /Q /C $COMMAND"  ;;
    *cacls*) ICACLS_ARGS="/T /C $COMMAND" ;;
    *xcacls*) ICACLS_ARGS="/T /C /Q $COMMAND" ;;
   esac
   
   IFS="$IFS "
  for ARG; do
   (type realpath 2>/dev/null >/dev/null && ARG=$(realpath "$ARG")
   ARG=$(${PATHTOOL:-cygpath}${PATHTOOL:+
-w} "${ARG%[/\\]}")
    ARG=${ARG%[\\/]}
    [ -d "$ARG" ] && D="-R "
    ARG="\"$ARG\""
    
    EXEC="${ICACLS:-icacls} $ARG ${ICACLS_ARGS}"
    [ "$TAKEOWN" = true ] && EXEC="takeown ${D}-F $ARG >${NUL:-/dev/null}${SEP:-; }$EXEC"
#    [ "$CMD" = true ] && EXEC="cmd /c \"${EXEC//\"/\\\"}\""
    [ "$PRINT" = true ] && { EXEC=${EXEC//\\\"/\\\\\"}; EXEC="echo \"${EXEC//\"/\\\"}\""; }
    [ "$DEBUG" = true ] && echo "+ $EXEC" 1>&2
    ${E:-eval} "$EXEC")
  done)
}

id3dump()
{
    ( IFS="
  ";
    unset FLAGS;
    while :; do
        case "$1" in
            -*)
                FLAGS="${FLAGS+$FLAGS
  }$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    id3v2 $FLAGS  -l "$@" | ${SED-sed} -n 's, ([^:]*)\(\[[^]]*\]\)\?:\s\+,: , ;; s,^\([[:upper:][:digit:]]\+\):,\1:,p'
    )
}

id3get()
{
    ( id3dump "$1" 2>&1 | ${GREP-grep} "^$2" | ${SED-sed} 's,^[^:=]*[:=]\s*,,' )
}

id3()
{
    $ID3V2 -l "$@" | ${SED-sed} "
  s,^\([^ ]\+\) ([^:]*):\s\?\(.*\),\1=\2,
   s,.* info for s\?,,
  /:$/! { /^[0-9A-Z]\+=/! { s/ *\([^ ]\+\) *: */\n\1=/g; s,\s*\n\s*,\n,g; s,^\n,,; s,\n$,,; s,\n\n,,g; }; }" | ${SED-sed} "/:$/ { p; n; :lp; N; /:\$/! { s,\n, ,g;  b lp; }; P }"
}

imagedate()
{
        (
        case "$1" in
                 -u | --unix*) UT=true ; shift ;;
         esac
        N=$#
         for ARG; do
        TS=$(exiv2 pr "$ARG" 2>&1| ${SED-sed} -n '/No\sExif/! s,.*timestamp\s\+:\s\+,,p' | ${SED-sed} 's,\([0-9][0-9][0-9][0-9]\):\([0-9]\+\):\([0-9][0-9]\),\1/\2/\3,')
        [ "$UT" = true ] && TS=$(date2unix "$TS" 2>/dev/null)
        O="$TS"

        [ $N -gt 1 ] && O="$ARG:$O"
        echo "$O"
    done)
}

imatch-some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}

implode()
{
 (unset DATA SEPARATOR;
  SEPARATOR="$1"; shift
  CMD='DATA="${DATA+$DATA$SEPARATOR}$ITEM"'
  if [ $# -gt 0 ]; then
    CMD="for ITEM; do $CMD; done"
  else
    CMD="while read -r ITEM; do $CMD; done"
  fi
  eval "$CMD"
  echo "$DATA")
}

importlibs()
{
    local lib IFS="|";
    for lib in $__LIBS__;
    do
        if ! source $shlibdir/$lib.sh 2> /dev/null; then
            echo "Error loading $lib.sh" 1>&2;
            return $?;
        fi;
    done
}

inc()
{
    expr "$1" + "${2-1}"
}

incv()
{
    eval "$1=\`expr \"\${$1}\" + \"${2-1}\"\`"
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
index()
{
    ( INDEX=`expr ${1:-0} + 1`;
    shift;
    echo "$*" | cut -b"$INDEX" )
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
indexarg()
{
    ( I="$1";
    shift;
    eval echo "\${@:$I:1}" )
}

<<<<<<< HEAD
=======
=======
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
index-dir()
{ 
    [ -z "$*" ] && set -- .;
    unset OPTS
    NAME=files
    while :; do
        case "$1" in 
            -l) pushv OPTS "-l"; NAME="$NAME-l"; shift ;;
            -n|--name) NAME="$2"; shift 2 ;;
            -x | --debug)
                DEBUG=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    ( exec 9>&2;
    [ "$(uname -m)" = "x86_64" ] && : ${R64="64"};
    for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD"; then
            echo "Cannot write to $PWD ..." 1>&2;
            exit;
        fi;
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP="$PWD/${RANDOM:-$$}.list";
        trap 'rm -f "$TEMP"; unset TEMP' EXIT;
        ( if type ${LIST_R:-list-r${R64}} 2> /dev/null > /dev/null; then
            CMD=${LIST_R:-list-r${R64}};
        else
            if type list-r 2> /dev/null > /dev/null; then
                CMD=${LIST_R:-list-r}
            else
                CMD=list-recursive;
            fi;
        fi;
        [ "$DEBUG" = true ] && echo "$ARG:+ $CMD" 1>&9;
        eval "$CMD $OPTS" ) 2> /dev/null > "$TEMP";
        ( install -m 644 "$TEMP" "$PWD/$NAME.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/$NAME.list";
        wc -l "$PWD/$NAME.list" 1>&2 );
    done )
}

index-of()
{
    ( needle="$1";
    index=0;
    while [ "$#" -gt 1 ]; do
        shift;
        if [ "$needle" = "$1" ]; then
            echo "$index";
            exit 0;
        fi;
        index=`expr "$index" + 1`;
    done;
    exit 1 )
}

index()
{
    ( INDEX=`expr ${1:-0} + 1`;
    shift;
    echo "$*" | cut -b"$INDEX" )
}

index-tar()
{
    ( while :; do
      case "$1" in
         -s | --save ) SAVE=true; shift ;;
         -d | --debug ) DEBUG=true; shift ;;
         *) break ;;
         esac
         done

FILTERCMD='${SED-sed} "s,^\./,,"'
if [ $# -gt 1 ]; then
        FILTERCMD=${FILTERCMD:+$FILTERCMD'|'}'${SED-sed} "s|^|$ARG:|"';
    else
        unset FILTERCMD;
    fi
    [ "$SAVE" = true ] && OUTPUT="\${ARG%.tar*}.list"

    CMD="tar -tf \"\$ARG\" 2>/dev/null ${FILTERCMD+|$FILTERCMD}${OUTPUT:+>$OUTPUT}"
    [ "$DEBUG" = true ] && DBG="echo \"tar -tf \$ARG${OUTPUT:+ >$OUTPUT}\"; "
   eval "for ARG; do $DBG eval \"\$CMD\" ; done")
}

indexv()
{
 (shiftv "$@"
  eval "echo \"\${$1%%[\$IFS]*}\"")
}

in-path()
{
    local dir IFS=:;
    for dir in $PATH;
    do
        ( cd "$dir" 2> /dev/null && set -- $1 && test -e "$1" ) && return 0;
    done;
    return 127
}

inputf()
{
    local __line__ __cmds__;
    __line__=$IFS;
    __cmds__="( set -- \$__line__; $*; )";
    IFS="$__line__";
    while read __line__; do
        eval "$__cmds__";
    done
}

installpkg() {
 (IFS="
"
  ARGS="$*"
  if [ "${PKGDIR+set}" != set ]; then
    set -- $(ls -d /m*/*/pmagic/pmodules{/extra,} 2>/dev/null)
    test -d "$1" && PKGDIR="$1"
    : ${PKGDIR="$PWD"}
  fi
  for ARG in $ARGS; do
     case "$ARG" in
       *://*) wget ${PKGDIR:+-P "$PKGDIR"} -c "$ARG"; ARG="$PKGDIR/${ARG##*/}" ;;
     esac
     command installpkg "$ARG"
  done)
}

inst-slackpkg()
{
    ( . require.sh;
    require array;
    while :; do
        case "$1" in
            -a)
                ALL=true;
                shift
            ;;
            -f)
                FILE=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    INSTALLED=;
    EXPR="$(grep-e-expr "$@")";
    [ "$FILE" = true ] && EXPR="/$EXPR[^/]*\$";
    PKGS=` ${GREP-grep} -H -E "$EXPR" $([ "$PWD" = "$HOME" ] && ls -d slackpkg*)  ~/slackpkg* | ${SED-sed} 's,.*:/,/, ; s,/slackpkg[^./]*\.list:,/,'`;
    if [ -z "$PKGS" ]; then
        echo "No such package $EXPR" 1>&2;
        exit 2;
    fi;
    set -- $PKGS;
    IFS="
$IFS";
    if [ "$ALL" != true -a $# -gt 1 ]; then
        echo "Multiple packages:" 1>&2;
        echo "$*" 1>&2;
        exit 2;
    fi;
    for PKG in "$@";
    do
        NAME=${PKG##*/};
        NAME=${NAME%.t?z};
        if ! array_isin INSTALLED "$NAME"; then
            echo "Installing $PKG ..." 1>&2;
            ( echo;
            installpkg "$PKG" 2>&1;
            echo ) >> install.log;
            array_push_unique INSTALLED "$NAME";
        else
            echo "Package $PKG already installed" 1>&2;
        fi;
    done )
}

is-absolute()
{
    ! is-relative "$@"
}

is-a-tty()
{ 
    eval "tty  0<&${1:-1} >/dev/null"
}

is-binary()
{
    case `file - <$1` in
        *text*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}

is-checking()
{ 
    ps -aW | grep --color=auto --line-buffered --text -q chkdsk
}

isin() {
 (needle="$1";
  while [ "$#" -gt 1 ]; do
    shift;
    test "$needle" = "$1" && exit 0;
  done;
  exit 1)
}

is-interactive()
{
    test -n "$PS1"
}

is-mounted()
{
    isin "$1" $(mounted-devices)
}

is-object()
{
    case `file - <$1` in
        *ELF* | *executable*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

iso-extract()
{
    ( NAME=`basename "$1" .iso`;
    DEST=${2:-"$NAME"};
    7z x -o"$DEST" "$1" )
}

is-pattern()
{
    case "$*" in
        *'['*']'* | *'*'* | *'?'*)
            return 0
        ;;
    esac;
    return 1
}

is-relative()
{
    case "$1" in
        /*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}

is-true()
{
    case "$*" in
        true | ":" | "${FLAGS_TRUE-0}" | yes | enabled | on)
            return 0
        ;;
    esac;
    return 1
}

is-updating()
{ 
    [ "$(handle -p $(ps -aW|grep locate32|awkp)|wc -l)" -ge 20 ]
}

is-upx-packed()
{
    list-upx "$1" | ${GREP-grep} -q "\->.*$1"
}

is-url()
{
    case $1 in
        *://*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

is-var()
{
    case $1 in
        [!_A-Za-z]* | *[!_0-9A-Za-z]*)
            return 1
        ;;
    esac;
    return 0
}

join-lines() { 
 (c=${1-\\};
  ${SED-sed} '
	:lp
    s|\(\s*\)\'$c'\r\?\n\(\s*\)\([^\n]*\)$| \3|
    /\'$c'\r\?$/  { 
		    $! {
				    N
						b lp
				} 
				s,\'$c'$,,
    }')
}

juce-mingw-build() { 
 (: ${MSYS_HOME="e:/msys64"}
  : ${MINGW_HOME="$MSYS_HOME/mingw64"}
  unset VARS TARGETS DIRS
  while [ $# -gt 0 ]; do
    ARG="$1"; shift
    if [ -d "$ARG" ]; then
      pushv DIRS "$ARG"
      continue
    fi    
    case "$ARG" in
      *=*) pushv VARS "$ARG"; continue ;;
      *) pushv TARGETS "$ARG" ;;
    esac    
  done 
  [ -z "$DIRS" ] && DIRS=.
  var_dump VARS DIRS TARGETS
  export PKG_CONFIG_PATH="$(cygpath -a "${MINGW_HOME}"/*/pkgconfig | implode :)" PKG_CONFIG_SYSROOT_DIR="$(cygpath -am "${MSYS_HOME}")"

  for P in $DIRS; do 
    DIR=${P%/Builds*}
	P=$DIR/Builds/MinGW*
    (cd "$DIR"
     set -- *.jucer; J="$1"
	  for JUCER in {Pro,Intro}jucer; do (set -x; $JUCER --resave "$J") && {
	   $JUCER --add-exporter "MinGW Makefile" "$J" 
	 }
  set -x; make -C Builds/MinGW*  $VARS $TARGETS && exit 0
	done) || exit $?
	
  done)
}

killall-w32()
{
    ( IFS="
   ";
    PIDS=$(IFS="|"; ps.exe -aW |${GREP-grep} -i -E "($*)" | awk '{ print $1 }');
    kill.exe -f $PIDS )
}

lastarg()
{
    ( eval echo "\${$#}" )
}

launch-x11() {
 (IFS=" "
  CMD="$*"

  : ${DISPLAY:=":0"}

  export DISPLAY
  xhost +

  eval "$CMD" 2>/dev/null >/dev/null &)
}

len()
{
    eval "echo \${#$1}"
}

lftpls()
{
    ( lftp "$1" -e "find $1/; exit" )
}

linedelay()
{
    unset o;
    while read i; do
        test "${o+set}" = set && echo "$o";
        o=$i;
    done;
    test "${o+set}" = set && echo "$o"
}

link-mpd-music-dirs()
{
    ( : ${DESTDIR=/var/lib/mpd/music};
    mkdir -p "$DESTDIR";
    chown mpd:mpd "$DESTDIR";
    for ARG in "$@";
    do
        ( NAME=$(echo "$ARG" |${SED-sed} " s,^/mnt,, ; s,^/media,,g; s,/,-,g; s,^-*,, ; s,-*$,,");
        ( set -x;
        ln -svf "$ARG" "$DESTDIR"/"$NAME" ) );
    done )
}

list() {
   echo "$*"
}

list_lib_symbols()
{
 (unset OPTS
  while :; do
    case "$1" in
        -*) OPTS="${OPTS:+$OPTS
}$1" ;;
        *) break ;;
    esac
  done
  CMD='case "$LIB" in
 *.a) ${NM-nm} -A $OPTS "$LIB" ;;
 *.so*) ${OBJDUMP-objdump} -T $OPTS "$LIB" ;;
 esac | addprefix "$LIB: "'
  if [ $# -gt 0 ]; then
    CMD="for LIB; do $CMD; done"
  else
    CMD="while read -r LIB; do $CMD; done"
  fi
  eval "$CMD")
}

list-7z() {
 (: ${_7Z=7z}
 CR=$'\r'
  while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  fi
  }
  output_line() {
  case "$PREV" in
    "$DN"/* | "$DN/" | "$DN") ;;
    *) : echo "$DN/" ;;
    esac
  #    [ -z "$NAME" ] && unset F FP
  if [ "$FN" = "$PREV/" ]; then
    PREV="$PREV/"
  fi
  case "$PREV" in
    */)
    case "$FN" in
      $PREV/*) ;;
      *) unset PREV ;;
    esac
    ;;
    esac
  if [ -n "PREV" -a "$FN" != "$PREV" -a "$FN" != "$PPREV" ]; then
    case "$PREV" in
      */) ;;
      *)
      DIR="${PREV}"
        while :; do
          [ "$DIR" = "${DIR%/*}" ] && break
          DIR="${DIR%/*}"
         #echo "DIR='$DIR' PREVDIR='$PREVDIR'" 1>&2
        if [ -z "$PREVDIR" -o "${PREVDIR#$DIR/}" = "$PREVDIR" ]; then
         #[ -n "$PREVDIR" ] && output "$PREVDIR"
         PREVDIR="$DIR/"
        fi

        case "$DIR" in
          ${PREVDIR%/}/*) continue ;;
        esac
        case "${PREVDIR%/}" in
          ${DIR}/*) continue ;;
        esac
        [ "$DIR/" != "$PREVDIR" ] && output "$DIR/"
          case "${PREVDIR%/}" in
            $DIR | $DIR/*) ;;
            *) PREVDIR="$DIR/" ;;
          esac
        done
       ;;
    esac
    output "$PREV"
  fi
  PPREV="$PREV"
  if [ -n "$FN" -a "$FN" != "$PREV" ]; then
    #output "$FN"
    PREV="$FN"
  fi
  case "$PREV" in
    */) PREVDIR="$PREV" ;;
  esac
  [ -z "$NAME" ] && unset A F FP PSZ SZ T FN
  }
  while [ $# -gt 0 ]; do
   (B=${1##*/}
    case "$1" in
      *://*) INPUT="wget -q -O - \"\$1\""; ARCHIVE=$1 ;;
      *) ARCHIVE=$1  ;;
    esac
    case "$1" in
      *.t?z | *.tbz2)
        T=${1%.t?z}
        T=${T%.tbz2}
        T=$T.tar
				[ -n "$INPUT" ] && {
								INEXT=${1##*.t}
								INNAME=${1##*/}
								INNAME=${1%.*}.${INEXT}
								NOA=""
        }
			
        INPUT="${INPUT:+$INPUT | }${_7Z} x${INPUT:+ -si\"$INNAME\"} -so${NOA:- -si\"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${T##*/}\"";  CMD="${_7Z} l -slt $OPTS"
        ;;
      *.deb) CMD="HANDLER='7z x -si\"\$N\" -so | 7z l -slt -si\"x.tar\"' decode-ar" ;;
      *.tar.*) INPUT="${INPUT:+$INPUT | }${_7Z} x -so${ARCHIVE+ ${INPUT:+ -si}\"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${B%.*}\"";  CMD="${_7Z} l -slt $OPTS" ;;
      *) CMD="${_7Z} l -slt $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si\"${1##*/}\""
    fi
    ([ "$DEBUG" = true -o "$DEBUG" = : ] && echo "CMD: $CMD" 1>&2
    #[ "$DEBUG" = true -o "$DEBUG" = : ] && CMD="set -x; $CMD"
     eval "($CMD; echo) 2>/dev/null" ) |
    { IFS=" $CR"; unset PREV; while read -r NAME EQ VALUE; do      
        case "$NAME" in
          "Type") T=${VALUE}; continue ;;
          "Path") F=${VALUE//"\\"/"/"}; continue ;;
          "Folder") [ "$VALUE" = + ] && FP="/"; continue       ;;
          "Attributes") A=${VALUE}; continue ;;
          "Size") SZ=${VALUE}; continue ;;
          "Packed Size") PSZ=${VALUE}; continue ;;
          "----------") T=; continue ;;
          "Block"|"Blocks"|"CRC"|"Encrypted"|"Method"|"Modified"|"Solid") continue ;;
  "--" | \
  "7-Zip" | "Headers" | "Listing" | "Packed" | "Physical") continue ;;
          *) #echo "NAME='$NAME'" 1>&2
            ;;
        esac
        [ -n "$T" ] && continue
        case "$A" in
          D*) FP="/" ;;
        esac
        FN="$F$FP"
        DN="${F%/*}"
        output_line
      done
      output_line
    }
    ) || exit $?
    shift
  done)
}

list-broken-links() {
  (for ARG; do
    DIR=`dirname "$ARG"`
    BASE=`basename "$ARG"`

    TARGET=$(cd "$DIR"; readlink "$BASE")

    ABS="$DIR/$TARGET"

    test -e "$ABS" || echo "$ARG"
   done)
}

list-deb() {
 (trap 'exit 1' INT
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
  for ARG in "$@"; do
   (set -e
    trap 'rm -rf "$TEMP"' EXIT
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
    case "$ARG" in
      *://*)
        if type wget >/dev/null 2>/dev/null; then
          wget -P "$TEMP" -q "$ARG"
        elif type curl >/dev/null 2>/dev/null; then
          curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
        elif type lynx >/dev/null 2>/dev/null; then
          lynx -source >"$TEMP/${ARG##*/}" "$ARG"
        fi || exit $?
        DEB="${ARG##*/}"
      ;;
      *) DEB=$(realpath "$ARG") ;;
    esac
    cd "$TEMP"
    set -- $( ("${AR-ar}" t "$DEB" || list-7z "$DEB") 2>/dev/null |uniq |${GREP-grep} "data\.tar\.")
    if [ $# -le 0 ]; then
      exit 1
    fi
    case "$1" in
      *.bz2) TAR_ARGS="-j" ;;
      *.xz) TAR_ARGS="-J" ;;
      *.gz) TAR_ARGS="-z" ;;
      *.tar) TAR_ARGS="" ;;
    esac

   ( { "${AR-ar}" x "$DEB" "$1"; test -e "$1"; } ||
    7z x "$DEB" "$1") 2>/dev/null
    "${TAR-tar}" $TAR_ARGS -t -f "$1" 2>/dev/null | while read -r LINE; do
      case "$LINE" in
        ./) LINE="/" ;;
        ./?*) LINE="${LINE#./}" ;;
      esac
      output "$LINE"
    done) ||
    output "ERROR" 1>&2
  done)
}

list-devices-by()
{ 
 (TMP=`mktemp` TMP2=`mktemp` IFS=" "
  trap 'rm -f "$TMP"' EXIT

	{
    ls -ldn --time-style=+%s -- /dev/disk/by-{label,uuid}/* 
    ls -ldn --time-style=+%s -- /dev/*/* 2>/dev/null |sed -n '\|dev/disk|d; \|dev/block|d; \|dev/mapper|d; \| -> \.\./dm-|p'
	} >"$TMP2" 2>/dev/null; RET=$?; 
  [ "$RET" != 0 ] && exit $RET
  sort -t'>' -k2 <"$TMP2" >"$TMP"

  while read MODE N U G S T F __ L ; do
    while :; do
      unset LABEL UUID TYPE
            read MODE2 N2 U2 G2 S2 T2 F2 __ L2


            D=/dev/${L##*/}     
						[ -n "$D" -a -d "$D" ] && continue  2

            MAGIC=`file -k - <"$D"`
            [ "$DEBUG" = true ]  && echo  "MODE='$MODE' N='$N' F='$F' D='$D'"  1>&2

						case "$D" in
										/dev/dm-*) D="$F" ;;
						esac


            case "$F" in
                    */by-label/*) LABEL=${F##*/} ;;
                    */by-uuid/*) UUID=${F##*/} ;;
            esac

            [ "$L" = "$L2" ] && 
            case "$F2" in
                    */by-label/*) LABEL=${F2##*/} ;;
                    */by-uuid/*) UUID=${F2##*/} ;;
            esac  

              case "$MAGIC" in
                      *NTFS*) TYPE="ntfs" ;;
                      *ext2*) TYPE="ext2" ;;
                      *ext3*) TYPE="ext3" ;;
                      *ext4*) TYPE="ext4" ;;
                      *FAT\ \(32*) TYPE="vfat" ;;
                      *FAT\ *) TYPE="fat" ;;
                      *\ filesystem*) TYPE=${MAGIC%%" filesystem"*}; TYPE=${TYPE##*" "} ;;
                      *\ swap*) TYPE="swap" ;;
                      *) TYPE= ;;
              esac
						[ -z "$LABEL" ] && LABEL=${F##*/}

            echo "$D:${LABEL:+ LABEL=\"$LABEL\"}${UUID:+ UUID=\"$UUID\"}${TYPE:+ TYPE=\"$TYPE\"}"
            
            
        if [ "$L" != "$L2" ]; then
              N=$N2; U=$U2; G=$G2; S=$S2; T=$T2; F=$F2 L=$L2
              continue
      fi
      break
    done

           
  done <"$TMP")

  #ls -d /dev/disk/by-label/* | for_each -f 'echo "$(readlink -f "$1"): LABEL=\"${1##*/}\""';
  #ls -d /dev/disk/by-uuid/* | for_each -f 'echo "$(readlink -f "$1"): UUID=\"${1##*/}\""'
}

list-dotfiles()
{
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | ${GREP-grep} "/.${ARG#.}\$";
    done )
}

list-files()
{
    ( OUTPUT=">";
    OUTFILE=".files.file.tmp";
    while :; do
        case "$1" in
            -v)
                OUTPUT="| tee ";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    NL="
";
    FILTER="xargs -d \"\$NL\" file | ${SED-sed} \"s|^\.\/|| ;; s|:\s\+|: |\" ${OUTPUT}\"\${OUTFILE}\"";
    for ARG in "$@";
    do
        ( cd "$ARG";
        find . -xdev -not -type d | eval "$FILTER";
        mv -f .files.file.tmp files.file;
        echo "Created $PWD/files.file" 1>&2 );
    done )
}

list-iso() {
 (for ISO; do
    isoinfo -R -l -i "$ISO" |
    decode-ls-lR.sh | sed -u "s|^/||"
  done)
}

list-lastitem()
{
    ${SED-sed} -n '$p'
}

list_lib_symbols()
{
 (unset OPTS
  while :; do
    case "$1" in
        -*) OPTS="${OPTS:+$OPTS
}$1" ;;
        *) break ;;
    esac
  done
  CMD='case "$LIB" in
 *.a) ${NM-nm} -A $OPTS "$LIB" ;;
 *.so*) ${OBJDUMP-objdump} -T $OPTS "$LIB" ;;
 esac | addprefix "$LIB: "'
  if [ $# -gt 0 ]; then
    CMD="for LIB; do $CMD; done"
  else
    CMD="while read -r LIB; do $CMD; done"
  fi
  eval "$CMD")
}

list-mediapath() {
 (unset CMD
  while :; do
    case "$1" in
      -b|-c|-d|-e|-f|-g|-h|-k|-L|-N|-O|-p|-r|-s) FILTER="${FILTER:+$FILTER | }filter-test $1"; shift ;;
      -x|-debug|--debug) DEBUG=true;  shift ;;
      -m|--mixed|-M|--mode|-u|--unix|-w|--windows|-a|--absolute|-l|--long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1"; shift ;;
      -*) OPTS="${OPTS:+$OPTS }$1"; shift ;;
      --) shift; break ;;
      *) break ;;
      esac
  done
  for ARG; do ARG=${ARG//" "/"\\ "}; ARG=${ARG//"("/"\\("};  ARG=${ARG//")"/"\\)"}; 
   CMD="${CMD:+$CMD; }set -- $MEDIAPATH/${ARG#/} ; IFS=\$'\\n'; ls -1 -d $OPTS -- \$* 2>/dev/null | grep -v '\\*'"; done

  [ -n "$PATHTOOL_OPTS" ] && CMD="${PATHTOOL:+$PATHTOOL ${PATHTOOL_OPTS:--m}} \$($CMD)"
  #CMD="for ARG; do $CMD; done"
  [ -n "$FILTER" ] &&	 CMD="($CMD) | $FILTER"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
  eval "$CMD")
}

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

list-nolastitem()
{
    ${SED-sed} '$d'
}

list-path()
{
  (IFS=":"; find $PATH -maxdepth 1 -mindepth 1 -not -type d)
}

list-rar() {
 (while :; do
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  fi
  }
  for ARG; do
   (IFS="/\\"
    LINENO=0
    HEADER_OK="false"
    unrar v "$ARG" | while read -r LINE; do
      LINENO=$((LINENO + 1))
      case "$LINE" in
        -------------------------------------------------------------------------------*)
          HEADER_OK="true"
          continue
        ;;
        "  "*)
          continue
        ;;
      esac
      "$HEADER_OK" || continue

      LINE=${LINE#" "}
      LINE=${LINE%$'\r'}
      #LINE=${LINE//"\\"/"/"}

      output $LINE
    done)
  done)
}

list-recursive()
{
    ( NL="
";
    unset ARGS;
    while :; do
        case "$1" in
            -s | -save)
                SAVE=true;
                shift
            ;;
            -a | -o | -maxdepth | -amin | -atime | -cnewer | -fstype | -group | -iname | -iwholename | -links | -mmin | -name | -path | -wholename | -uid | -user | -fprintf | -fprint | -exec | -ok | -execdir)
                ARGS="${ARGS:+$ARGS$NL}$1${NL}$2";
                shift 2
            ;;
            -print | -and | -follow | -depth | -mount | --version | -ignore_readdir_race | -N | -false | -nogroup | -readable | -executable | -type | -delete | -print | -prune)
                ARGS="${ARGS:+$ARGS$NL}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    for ARG in "$@";
    do
        ( cd "$ARG";
        CMD='find . $ARGS -xdev  | while read -r FILE; do test -d "$FILE" && echo "$FILE/" || echo "$FILE"; done | ${SED-sed} "s|^\.\/||"';
        [ "$SAVE" = true ] && CMD="$CMD | { tee .${FILENAME:-files}.${TMPEXT:-tmp}; mv -f .${FILENAME:-files}.${TMPEXT:-tmp} ${FILENAME:-files}.${EXT:-list}; echo \"Created \$PWD/${FILENAME:-files}.${EXT:-list}\" 1>&2; }";
        eval "$CMD" );
    done )
}

list-rpm() {
 (NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
  LOG="$PWD/$(basename "$0" .sh).log"
  exec_cmd() {
   (
    echo "CMD: $@" 1>&2
    echo "CMD: $@" >>"$LOG"
    exec "$@")
  }
  for ARG in "$@"; do
   (set -e
    trap 'rm -rf "$TEMP"' EXIT QUIT TERM INT
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
    case "$ARG" in
      *://*)
        if type wget >/dev/null 2>/dev/null; then
          exec_cmd wget -P "$TEMP" -q "$ARG"
        elif type curl >/dev/null 2>/dev/null; then
          exec_cmd curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
        elif type lynx >/dev/null 2>/dev/null; then
          exec_cmd lynx -source >"$TEMP/${ARG##*/}" "$ARG"
        fi || exit $?
        RPM="${ARG##*/}"
      ;;
      *) RPM=$(realpath "$ARG") ;;
    esac
    cd "$TEMP"
    set -- $( (    7z l "$RPM" |${SED-sed} -n "\$d; /^----------/ { n; /^------------------/ { :lp; \$! { d; b lp; }; } ; /^-/! { / files\$/! s|^...................................................  ||p }; }"  ||
    (exec_cmd "${RPM2CPIO-rpm2cpio}" >/dev/null; R=$?; [ $R -eq 0 ] && echo "$(basename "$RPM" .rpm).cpio"; exit $R) ) 2>/dev/null |uniq |${GREP-grep} "\\.cpio\$")
    if [ $# -le 0 ]; then
      exit 1
    fi
    CPIOCMD="exec_cmd cpio -t 2>/dev/null"
    case "$1" in
      *.bz2) CPIOCMD="bzcat | $CPIOCMD" ;;
      *.xz) CPIOCMD="xzcat | $CPIOCMD" ;;
      *.gz) CPIOCMD="zcat | $CPIOCMD" ;;
      *.cpio) ;;
    esac
    ((set -x; exec_cmd 7z x -so "$RPM" "$1" ) ||
   { exec_cmd "${RPM2CPIO-rpm2cpio}" <"$RPM"; }
     ) 2>/dev/null |
    eval "$CPIOCMD" | while read -r LINE; do
      case "$LINE" in
        ./) LINE="/" ;;
        ./?*) LINE="${LINE#./}" ;;
      esac
      output "$LINE"
    done) ||
    output "ERROR" 1>&2
  done)
}

list() {
   echo "$*"
}

list-slackpkgs()
{
    ( [ -z "$*" ] && set -- .;
    for ARG in "$@";
    do
        find "$ARG" -type f -name "*.t?z";
    done | ${SED-sed} 's,^\./,,' )
}

list-subdirs()
{
    ( find ${@-.} -mindepth 1 -maxdepth 1 -type d | ${SED-sed} "s|^\./||" )
}

list-tolower()
{
    tr [:{upper,lower}:]
}

list-toupper()
{
    tr [:{lower,upper}:]
}

list-upx()
{
    upx -l "$@" 2>&1 | ${SED-sed} '1 { :lp; N; /^\s*--\+/! b lp; d; }' | ${SED-sed} '$ { /[0-9]\sfiles\s\]$/d; } ; /^\s*[- ]\+$/d'
}

list-visual-studios() {
 (NL="
"
  IFS="$NL"
  SP=" "

  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      -c | -cl | --cl | --compiler) pushv O "CL" ; shift ;;
      -b | -vsdir | --vsdir) pushv O "VSDIR" ; shift ;;
      -d | -vcdir | --vcdir) pushv O "VCDIR" ; shift ;;
      -v | -vcvars | --vcvars) pushv O "VCVARS"; shift ;;
      -e | -devenv | --devenv) pushv O "DEVENV"; shift ;;
      -t | -tool | --tool) pushv T "$(str_toupper "$2")"; pushv O "$(str_toupper "$2")"; shift 2 ;; -t=* | -tool=* | --tool=*) pushv T "$(str_toupper "${1#*=}")"; pushv O "$(str_toupper "${1#*=}")"; shift ;;
      -p | -pathconv | --pathconv) PATHCONV="$2";  shift 2 ;; -p=* | -pathconv=* | --pathconv=*) PATHCONV="${1#*=}"; shift ;;
      -t*) pushv T "${1#-?}"; pushv O "$(str_toupper TOOL_${1#-t})"; shift ;;

      *) break ;;
    esac
  done
  : ${PATHCONV="cygpath$NL-w"}
  PATHCONV=${PATHCONV//" "/"$NL"}



  [ -z "$O" ] && O="CL"

  [ $# -eq 0 ] && PTRN="*" || PTRN="$(set -- $(vs2vc -c -0 "$@"); IFS=","; echo "$*")"

  case "$PTRN" in
    *,*) PTRN="{$PTRN}" ;;
  esac

  PTRN="\"$($PATHCONV "${ProgramFiles:-$PROGRAMFILES}")\"{,\" (x86)\"}/*Visual\ Studio\ ${PTRN}*/VC/bin/{,*/}cl.exe"
  echo "PTRN=$PTRN" 1>&2
  eval "ls -d $PTRN" 2>/dev/null |

#  set -- "$($PATHTOOL "${ProgramFiles:-$PROGRAMFILES}")"{," (x86)"}/*Visual\ Studio\ [0-9]*/VC/bin/{,*/}cl.exe
  #ls -d -- "$@" 2>/dev/null |
  sort -V | while read -r CL; do
    case "$CL" in
      *amd64/*) ARCH="Win64" ;;
      *arm/*) ARCH="ARM" ;;
      *ia64/*) ARCH="IA64"   ;;
      *) ARCH="" ;;
    esac


    TARGET=${CL##*/bin/}; TARGET=${TARGET%%cl.exe}; TARGET=${TARGET%/}
    #: ${TARGET:="x86"}

    VSDIR="${CL%%/VC*}"
    VCDIR="$VSDIR/VC"
    VCVARS="call \"$($PATHCONV "$VSDIR/VC/vcvarsall.bat")\"${TARGET:+ $TARGET}"
    VSVER=${VSDIR##*/}
    VSVER=${VSVER##*"Visual Studio "}


    DEVENV="$VSDIR/Common7/IDE/devenv"

    #echo "VSDIR: $VSDIR VSVER: $VSVER" 1>&2
   VSNAME="Visual Studio $(vc2vs "${VSVER}")${ARCH:+ $ARCH}"
   for VAR in $O; do
	 case "$VAR" in
	   DEVENV ) EXT=".exe" ;;
	   *) EXT="" ;;
	 esac
     #CMD="\${PATHCONV:-echo} \"\${$VAR}\$EXT\""
     CMD="echo \"\${$VAR}\$EXT\""
     [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
     eval "$CMD"
   done
  done

  )
}

locate-filename()
{
    ( IFS="
 ";
    unset TEST_ARGS;
    while :; do
        case "$1" in
            -i)
                IGNORE_CASE=true;
                shift
            ;;
            -r)
                REGEXP=true;
                shift
            ;;
            -a | -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -s | -u | -w | -x)
                TEST_ARGS="${TEST_ARGS:+$TEST_ARGS
}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    LOCATE_ARGS=;
    if [ "$IGNORE_CASE" = true ]; then
        LOCATE_ARGS="${LOCATE_ARGS:+$LOCATE_ARGS
}-i" GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
}-i";
    fi;
    for EXPR in "$@";
    do
        if [ "$REGEXP" != true ]; then
            EXPR=${EXPR//"."/"\\."};
            EXPR=${EXPR//"?"/"."};
            EXPR=${EXPR//"*"/"[^/]*"};
            case "$EXPR" in
                *"[^/]*")

                ;;
                *)
                    EXPR="$EXPR\$"
                ;;
            esac;
            case "$EXPR" in
                "[^/]*"*)

                ;;
                *)
                    EXPR="^$EXPR"
                ;;
            esac;
            REGEXP=true;
        fi;
        if [ "$REGEXP" = true ]; then
            case "$EXPR" in
                *\$)

                ;;
                *)
                    EXPR="${EXPR%"[^/]*"}[^/]*\$"
                ;;
            esac;
            case "$EXPR" in
                ^*)
                    EXPR="/${EXPR#^}"
                ;;
            esac;
            EXPR=${EXPR//'.*'/'[^/]*'};
        fi;
        CMD='(set -x; locate $LOCATE_ARGS -r "$EXPR") ';
        if [ -n "$TEST_ARGS" ]; then
            CMD="$CMD | filter-test \$TEST_ARGS";
        fi;
        CMD="$CMD | (set -x ; ${GREP-grep} \$GREP_ARGS \"\${EXPR#/}\") ";
        eval "$CMD";
    done )
}

lookup-grub-devicemap()
{ 
	arg=$(realpath "$1")
    ( IFS='	 ';
    while read -r grubdisk diskdev; do
        realdev=$(realpath "$diskdev");
        test -n "$realdev" || continue;
        case "$arg" in 
            $realdev*)
                echo "$grubdisk";
                exit
            ;;
        esac;
    done ) < "${devicemap:-device.map}"
}

ls-dirs() {
 ([ $# -le 0 ] && set -- .
  for ARG; do
    ls --color=auto -d -- "$ARG"/{,.[!.]}*/
  done) 2>/dev/null | ${SED-sed} "s|^\\./|| ;; s|/\$||"
}

ls-files()
{
 ([ $# -le 0 ] && set -- .
  while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
      *) break ;;
	esac
  done
  for ARG; do
      ls --color=auto -d $OPTS -- "$ARG"/{,.[!.]}*
  done) 2>/dev/null | filter-test -f| ${SED-sed} "s|^\\./||; s|/\$||"
}

lsof-win()
{
#  (for PID in $(ps -aW | ${SED-sed} 1d |awkp 1); do
#    handle -p "$PID" |${SED-sed} "1d;2d;3d;4d;5d; s|^|$PID\\t|"
#  done)
 (while :; do
    case "$1" in
      -p) PIDS="${PIDS+$PIDS$IFS}$2"; shift 2 ;;
      -p=*) PIDS="${PIDS+$PIDS$IFS}${1#*=}"; shift ;;
      -p*) PIDS="${PIDS+$PIDS$IFS}${1#-p}"; shift ;;
      *) break ;;
    esac
  done
  if [ -n "$PIDS" ]; then
    CMD='for PID in $PIDS; do EXE=$(proc-by-pid $PID); echo "${EXE##*[\\/]}.exe pid: $PID"; handle -p $PID; done'
  else
    CMD='handle -a'
  fi
  eval "$CMD" 2>&1 | {
  TAB="	"
  CR=""
  IFS="$CR"
  while read -r LINE; do
    case "$LINE" in
      *"pid: "*)
        LSOF_PID=${LINE##*"pid: "}
        LSOF_PID=${LSOF_PID%%" "*}
        EXE=${LINE%%" "*}
        EXE=${EXE%.[Ee][Xx][Ee]}
      ;;
      "" | "Copyright (C) 1997-2014 Mark Russinovich" | "Handle v4.0" | "Sysinternals - www.sysinternals.com") continue ;;

      *) printf "%-10s %5d %s\n" "$EXE" "$LSOF_PID" "$LINE" ;;
    esac
  done; }) |${SED-sed} -u 's,\\,/,g'
}

make_archpkg() {
    for ARG; do     
      (cd "$ARG"
      NAME=${PWD##*/}; NAME=${NAME%.pkg*}; NAME=${NAME%.tar*}
      set -x
      ${TAR:-tar} \
        --dereference \
        --recursion \
        --numeric-owner --owner=0 \
        --no-acls  --no-xattrs --posix \
        --exclude={"*.tmp","*~","*.rej","*.orig",".*.swp"} \
        -cvJf ../"$NAME.pkg.tar.xz"  .[[:upper:]]*  [!.]*); done
 }

make-arith()
{
    echo '$(('"$@"'))'
}

list-mediapath ()  {  ( unset CMD ; while :; do case "$1" in 

-b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s) FILTER="${FILTER:+$FILTER | }filter-test $1" ; shift ;;
 -x | -debug | --debug) DEBUG=true ; shift ;;
 -m | --mixed | -M | --mode | -u | --unix | -w | --windows | -a | --absolute | -l | --long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1" ; shift ;;
 -*) OPTS="${OPTS:+$OPTS }$1" ; shift ;;
 --) shift ; break ;;
 *) break ;;
 esac ; done ; for ARG in "$@" ; do ARG=${ARG//" "/"\\ "} ; ARG=${ARG//"("/"\\("} ; ARG=${ARG//")"/"\\)"} ; CMD="${CMD:+$CMD; }set -- $MEDIAPATH/${ARG#/} ; IFS=\$'\\n'; ls -1 -d $OPTS -- \$* 2>/dev/null | grep -v '\\*'" ; done ; [ -n "$PATHTOOL_OPTS" ] && CMD="${PATHTOOL:+$PATHTOOL ${PATHTOOL_OPTS:--m}} \$($CMD)" ; [ -n "$FILTER" ] && CMD="($CMD) | $FILTER" ; [ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2 ; eval "$CMD" ) ; }
make-browser-shortcuts () 
{ 
  . bash_profile.bash
   QUICKLAUNCH="$USERPROFILE/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch"
   echo "cd \"$QUICKLAUNCH\""
    l=$(list-mediapath -m 'P*/*'{Firefox,Chrome,Opera,SeaMonkey,QupZilla,Chromium,SpeedyFox,Waterfox,PaleMoon,Palemoon,Safari,K*Meleon}'*Portable*/'|removesuffix /);
    for x in $l;
    do
        y=$(basename "$x")
        z=$(ls -d -- "$x"/*Portable*.exe |head -n1)
        [ -n "$z" ] &&       z=$(cygpath -a "$z")
 [ -n "$z" -a -f "$z" ] && 
        echo "mkshortcut -n \"${y##*/}\" \"$z\"";
    done
}

[ "$(basename "${0#-}")" = "make-browser-shortcuts.sh" ] && make-browser-shortcuts 2>/dev/null

make-cfg-sh() { 
 (for ARG in "${@:-./configure}"; do
    HELP=$("$ARG" --help=recursive ); ( echo "$HELP" | ${GREP-grep} -q '^\s*--.*dir' ) || HELP=$( ("$ARG" --help ; echo "$HELP") |sort -t- -k2 -n -u ); ( echo "$HELP" | ${GREP-grep
-a
--line-buffered
--color=auto} -q '^\s*--' ) || HELP=$("$ARG" --help ); { 
      unset O; while read -r LINE; do
          case "$LINE" in 
              *--enable-[[:upper:]]* | *--with-[[:upper:]]* | *--without-[[:upper:]]* | *--disable-[[:upper:]]*)
                  continue
              ;;
              *\(*--*)
                  continue
              ;;
              *--enable* | *--disable* | *--with* | *--*dir*=*)
                  LINE=${LINE#*--}
              ;;
              *)
                  continue
              ;;
          esac
          LINE=${LINE%%" "*}; LINE=${LINE%%$'\t'*}; LINE=${LINE%%[\',]*}; BRACKET=false
          case "$LINE" in 
              *\[*\]*)
                  LINE=${LINE/"["/}; LINE=${LINE/"]"/}; BRACKET=TRUE
              ;;
          esac
          case "$LINE" in 
              *=*)
                  OPT=${LINE%%=*}; VALUE=${LINE#*=}
              ;;
              *)
                  OPT="$LINE"
              ;;
          esac
          case "$LINE" in 
              *\[* | *\]* | [0-9]*) continue

              ;;
          esac
          VAR=$(tr [[:upper:]] [[:lower:]] <<<"${OPT//"-"/"_"}"); WHAT= DEFAULT=
          case "$OPT" in 
              with* | without*)
                  WHAT=${VAR%%[-_]*}; VAR=${VAR#*_}
              ;;
              enable* | disable*)
                  WHAT=${VAR%%[-_]*}; #VAR=${VAR#*_}; VALUE=
          case "$WHAT" in 
                      enable)
                          DEFAULT=""
                      ;;
                      disable)
                          DEFAULT="true"
                      ;;
                  esac
              ;;
              *dir*)
                  WHAT=dir; VALUE=; ;;
              prefix)
                  WHAT=; VALUE=
              ;;
          esac
          VAR=${VAR%" "}
          case "$VAR" in 
            *able-[0-9]*) continue ;;
              build | target)
                  SUBST=\"\${$VAR:-\$host}\"
              ;;
              includedir | libdir | libexecdir | bindir | sbindir)
                  VALUE=\$prefix/${VAR%dir}; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              sysconfdir)
                  VALUE=\$prefix/etc; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              localstatedir)
                  VALUE=\$prefix/var; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              infodir | mandir | docdir | localedir)
                  VALUE=\$prefix/share/${VAR%dir}; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              *dir)
                  continue
              ;;
              *)
                  SUBST=\"\${$VAR}\"
              ;;
          esac
          case "$DEFAULT" in 
              "")

              ;;
              *)
                  pushv-unique V ": \${$VAR=\"$DEFAULT\"}"
              ;;
          esac
          case "$WHAT" in 
              *able| with | "")
                case "$WHAT"  in
                  *able) unset SUBST 
                  #[ "$WHAT" = enable ] && unset WHAT 
                  ;;
                esac

                  [ "$WHAT" = enable ] &&  VAR=${VAR#*[-_]}
                  pushv-unique O "  ${VAR:+\${$VAR:+--${WHAT:+$WHAT-}${OPT#*-}${SUBST:+=$SUBST}}} \\"
              ;;
              *)
                  pushv-unique O "  --$OPT${VALUE:+=$SUBST} \\"
              ;;
          esac
      done; echo "$V

$ARG \\
$O
"'  "$@"'
      } <<< "$HELP"; done )
}

make-playlists()
{ 
 
 VIDEOS=
 DATABASE=$(ls -d --  "$(cygpath -am "$USERPROFILE")"/AppData/*/Locate32/*.dbs | filter-filesize -gt 1k )
 
 msg "Acquiring videos using locate..."
 pushv VIDEOS "$( locate32.sh -c video )"
 
 msg "Acquiring videos using find-media.sh..."
 pushv VIDEOS "$( find-media.sh -c video )"
 
 wc -l <<<"$VIDEOS" 1>&2
 msg "Acquiring videos using find \$(list-mediapath ...)"
 pushv VIDEOS "$( for_each -f 'find "$1" -type f -not -name "*.part"' $(list-mediapath -m {,Downloads/}{Videos/,Porn/} ) | grep-videos.sh )"
 wc -l <<<"$VIDEOS" 1>&2
 
 msg "Merging videos..."
 VIDEOS=$(ls -td -- $(realpath $(sed 's,\r*$,, ; s,\\\+,/,g' <<<"$VIDEOS" |filter-test -e ))   2>/dev/null | sed 's,^/cygdrive,, ; s,^/\(.\)/\(.*\),\1:/\2,' | sort -f -u | filter-filesize -ge 15M)
 
 set -- $VIDEOS
 msg "Acquired $# videos."
 
 split_results() {
   L="videos-by-$NAME.list"; grep -vi porn/ <<<"$R" >"$L";   N=$(wc -l <"$L")
  msg "Wrote $N entries to $L."
  L="porn-by-$NAME.list"; grep -i porn/ <<<"$R" >"$L";   N=$(wc -l <"$L")
  msg "Wrote $N entries to $L."
 }
 write_playlist() {
    for LL in videos porn; do
      LN=$LL-by-$NAME
      msg "Writing $LN.m3u"
    eval 'make-m3u.sh $(<'$LN'.list) |sed "s|/|\\\\|g ; s|\\r*\$|\\r|" >'$LN'.m3u'
   done
    
    
 }
 for CMD in "ls -"{t,S}"d --"; do
   case "$CMD" in
   *-S*) NAME=size ;;
   *-t*) NAME=time ;;
   esac
   eval 'R=$('$CMD' "$@" 2>/dev/null)'
   
   split_results
   
   write_playlist
   
 done
 
for CMD in \
  "duration -m" \
  "duration" \
  "bitrate" \
  "resolution"; do
  NAME=${CMD//" "/""}
  OUT=$NAME.tmp
  EVAL="$CMD \"\$@\" >$OUT"
  msg "Executing: $EVAL"
  eval "$EVAL"
  
  R=$(sort -r -nk3 -t: "$OUT" | grep -v ":[0-4]\$" | cut -d: -f 1,2)
  
split_results
  write_playlist
done

}
 

make-sizes-tmp()
{
    ${SED-sed} -n '/ [0-9]\+ /p' $(list-mediapath 'ls-lR.list') | awkp 5 > $TEMP/sizes.tmp;
    for N in $(histogram.awk <$TEMP/sizes.tmp|${GREP-grep} -v '^1 '|awkp 2|sort -n); do
      test "$N" -le 0 && continue
      echo "/^[^ ]\+\s\+[0-9]\+\s\+[0-9]\+\s\+[0-9]\+\s\+$N /p"
      done |(set -x; tee $TEMP/sizes.${SED-sed} >/dev/null)
}

make-slackpkg()
{
    (IFS="
"
    require str

     : ${OUTDIR="$PWD"};
    [ -z "$1" ] && set -- .;
    ARGS="$*"
IFS=";, $IFS"
   set -- $EXCLUDE '*~' '*.bak' '*.rej' '*du.txt' '*.list' '*.log' 'files.*' '*.000' '*.tmp'
   IFS="
"
  EXCLUDELIST="{$(set -- $(for_each 'str_quote "$1"' "$@"); IFS=','; echo "$*")}"
    for ARG in $ARGS;
    do
        test -d "$ARG";
        cmd="(cd \"$ARG\" >/dev/null; tar --exclude=${EXCLUDELIST} -cv --no-recursion \$(echo .; find install/ 2>/dev/null; find * -not -wholename 'install*'  |sort ) |xz -0 -f  -c  > \"$OUTDIR/\${PWD##*/}.txz\")";
        echo + "$cmd" 1>&2;
        eval "$cmd";
    done
    )
}

map()
{
    from=$1 to=$2;
    shift;
    while shift && [ "$#" -gt 0 ]; do
        if var_isset "$from$1"; then
            var_set "$to$1" "`var_get "$from$1"`";
        fi;
    done;
    unset -v from to
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
match-devices()
{
    ( EXPR="$*";
    foreach-partition 'case $DEV:$TYPE:$UUID:$LABEL in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV: TYPE=\"$TYPE\" UUID=\"$UUID\" LABEL=\"$LABEL\"" ;; esac' )
}

match-mounted()
{
    ( EXPR="$*";
    foreach-mount 'case $DEV:$MNT:$TYPE:$OPTS in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV $MNT $TYPE $OPTS $A $B" ;; esac' )
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
match()
{
 (EXPR="$1"; shift
  CMD='case $LINE in
  $EXPR) echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
matchall()
{
    ( STR="$1";
    shift;
    while [ $# -gt 0 ]; do
        case "$STR" in
            $1)

            ;;
            *)
                exit 1
            ;;
        esac;
        shift;
    done;
    exit 0 )
}

matchany()
{
    ( STR="$1";
    shift;
    set -o noglob;
    for EXPR in "$@";
    do
        case "$STR" in
            *$EXPR*)
                exit 0
            ;;
            *)

            ;;
        esac;
    done;
    exit 1 )
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
match-devices()
{
    ( EXPR="$*";
    foreach-partition 'case $DEV:$TYPE:$UUID:$LABEL in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV: TYPE=\"$TYPE\" UUID=\"$UUID\" LABEL=\"$LABEL\"" ;; esac' )
}

match-mounted()
{
    ( EXPR="$*";
    foreach-mount 'case $DEV:$MNT:$TYPE:$OPTS in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV $MNT $TYPE $OPTS $A $B" ;; esac' )
}

<<<<<<< HEAD
match()
{
 (EXPR="$1"; shift
  CMD='case $LINE in
  $EXPR) echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

=======
max()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -gt "$i" ] && i="$1";
    done;
    echo "$i" )
}

=======
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
max-length()
{ 
    ( max=$1;
    shift;
    a=$*;
    l=${#a};
    [ $((l)) -gt $((max)) ] && a="${a:1:$((max - 3))}...";
    echo "$a" )
}

mime()
{
    local mime="$(decompress "$1" | bheader 8 | file -bi -)";
    echo ${mime%%[,. ]*}
}

min()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -lt "$i" ] && i="$1";
    done;
    echo "$i" )
}

<<<<<<< HEAD
=======
mime()
{
    local mime="$(decompress "$1" | bheader 8 | file -bi -)";
    echo ${mime%%[,. ]*}
}

<<<<<<< HEAD
=======
min()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -lt "$i" ] && i="$1";
    done;
    echo "$i" )
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
minfo()
{
    #timeout ${TIMEOUT:-10} \
   (IFS="$IFS"$'\r' ; CMD='mediainfo "$ARG" 2>&1'
    [ $# -gt 1 ] && CMD="$CMD | addprefix \"\$ARG:\""
    CMD="for ARG; do $CMD; done"
    eval "$CMD")  | ${SED-sed} '#s|\s\+:\s\+|: | ; s|\r||g; s|\s\+:\([^:]*\)$|:\1| ; s| pixels$|| ; s|: *\([0-9]\+\) \([0-9]\+\)|: \1\2|g '
}

<<<<<<< HEAD
min()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -lt "$i" ] && i="$1";
    done;
    echo "$i" )
=======
<<<<<<< HEAD
=======
#!/bin/bash
 
#MYNAME=`basename "$0" .sh`
mk-list-index() {
 
: ${TEMP="c:/Temp"}

volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
      eval "$ECHO"
  done)
}

[ -n "$LIST_R64" ] && LIST_R64=$(cygpath -w "$LIST_R64")

{ 
  echo "@echo off
"
  if [ $# -le 0 ]; then
    if [ "$(uname -o)" = Cygwin ]; then
      set -- /cygdrive/?
    fi
    set -- $(volname  $(df -l "$@" | sed 1d |sort -nk3 |awk '{ print $6 }' ) |grep -viE '(ubuntu|fedora|UDF Volume|opensuse|VS201[0-9]|ext[234]|arch)'|sed 's,/.*,,')
  fi
  for D; do 
    P=$(cygpath "$D\\")

    N=$(volname "$P")
    W=${D//"/"/"\\"}
    W=${W##\\}
    echo "echo Indexing $D ($N)
${D%%/*}
cd \\${W#?:}
${LIST_R64:-list-r64} >files.tmp
del /f files.list
move files.tmp files.list
"
  done 
} |
unix2dos |
 (set -x; tee "E:/Temp/list-index.cmd" >/dev/null)

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
mkbuilddir() {
 (Q=\"
  FS=/
  BS=\\	
  add_def() {
    V=$1
    shift
    old_IFS="$IFS"
    IFS=";"
    ARGS="$ARGS ^
  -D $V=${Q}${*//$FS/$BS}${Q}"
    IFS="$old_IFS"
    unset old_IFS
  }
  # output_vcbuild <target> <Project|Solution> [Configuration]
  output_vcbuild() {
    P="$2"
    case "$1" in
      *64*) T=x64 ;;
      *) : ${T:="Win32"} ;;
    esac
    case "$1" in
      *2008* | *9.0*) echo "vcbuild \"${P/vcxproj/vcproj}\"${3:+ \"$3${T:+|$T}\"}" ;;
      *) echo "msbuild \"${P}\"${3:+ /p:Configuration=\"$3\"}" ;;
    esac
  }
  while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -64 | --64 | -x64 | --x64 | -amd64 | --amd64 | -x86_64 | --x86_64) ARCH="amd64" ;;
      *) break ;;
    esac
  done
  
  for ARG; do
   (case "$ARG" in
       *.sln) VC=$(sln-version --vc "$ARG"); DIR=$(dirname "$ARG") ;;
       *) VC=$(vs2vc "${ARG##*/}") ; DIR="$ARG" ;;
    esac
    
    [ "$DEBUG" = true ] && debug "VC version: $VC"
   
    B=$(basename "$DIR")
    
   
    CL=$(vcget "$VC" CL)
    ARCH=$(vcget "$B" ARCH)
    CMAKEGEN=$(vcget "$VC-$ARCH" CMAKEGEN)
#    echo "ARCH=$ARCH" 1>&2
    VSA=${VS-$(vcget "$VC" VS)}${ARCH:+-$ARCH}
    ABSDIR=$(cd "$DIR" >/dev/null && pwd -P)
    SRCDIR=${ABSDIR%/build*}
	if [ -e "$SRCDIR/CMakeLists.txt" ] ; then
	  CMAKELISTS="$SRCDIR/CMakeLists.txt"
      CMAKELISTS_ADD=$( ${SED-sed} -n "s|.*add_subdirectory(\s*\([^ )]*\)\s*).*|$SRCDIR/\1/CMakeLists.txt|p"  "$SRCDIR/CMakeLists.txt" )
	  if [ -n "$CMAKELISTS_ADD" ]; then
		pushv_unique CMAKELISTS $CMAKELISTS_ADD
	  fi
	  PROJECT=$(${SED-sed} -n   's|.*project\s*(\s*\([^ )]\+\).*|\1|ip' "$SRCDIR/CMakeLists.txt")
	  CONFIGURE_CMD="
cmake -G \"$(vcget "$VC-$ARCH" CMAKEGEN)\"$ARGS ^
  %* ^
  ..\\..
"	  
	  BUILD_TYPE="RelWithDebInfo MinSizeRel Debug Release"
	else
	  SOLUTION=$(cd "$DIR" >/dev/null && ls -d *.sln)
	fi
    PREFIX="${SRCDIR##*/}\\${DIR##*/}"
    [ -n "$INSTALLROOT" ] && INSTALLROOT=$(${PATHTOOL:-echo} "$INSTALLROOT")
    if [ -n "$CMAKELISTS" ]; then
	  if [ -z "$INSTALLROOT" ] && ${GREP-grep
-a} -q -i "add_library\s*(" $CMAKELISTS ; then
		case "$SRCDIR" in
		  *-[0-9]*) INSTDIR=${SRCDIR##*/} ;;
		  *) INSTDIR=${SRCDIR##*/}-$(isodate.sh -r "$SRCDIR") ;;
		esac
		  INSTALLROOT="E:/Libraries/${INSTDIR}/${B}"
	  fi
	  if ${GREP-grep
-a} -q -i "install\s*(" $CMAKELISTS ; then
		INSTALL_CMD=$(output_vcbuild "$B" INSTALL.vcxproj "Release")
	  fi
	  add_def CMAKE_INSTALL_PREFIX "${INSTALLROOT:-%PROGRAMFILES%\\$PREFIX}"
	  add_def CMAKE_VERBOSE_MAKEFILE "TRUE"
	  for VAR in BUILD_SHARED_LIBS ENABLE_SHARED; do
	   if ${GREP-grep
-a} -q "$VAR" $CMAKELISTS ; then
	   add_def $VAR "TRUE"
	   fi
	  done
	  if [ -n "$__BUILD_TYPE" ]; then
		add_def CMAKE_BUILD_TYPE "$BUILD_TYPE"
	  fi
	fi
  if [ -z "$ARCH" ]; then
	pushv ARGS_LOOP 'for %%T in (Win32 x86) do if /I "%1" == "%%T" ('${nl}'  set TARGET=Win32'${nl}'  set ARCH=x86'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv ARGS_LOOP 'for %%T in (Win64 x64 AMD64) do if /I "%1" == "%%T" ('${nl}'  set TARGET=x64'${nl}'  set ARCH=amd64'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv IF_TARGET 'if "%TARGET%" == "" set TARGET=Win32'
	pushv IF_TARGET 'if "%ARCH%" == "" set ARCH=x86'
	 T="%TARGET%"
   else
	#IF_TARGET="if not \"%1\" == \"\" set ARGS=/target:\"%1\"${nl}"
	ADD_ARGS=" %ARGS%"
  fi
	VCBUILDCMD=$(output_vcbuild "$(vcget "$VC" VS ARCH)" ${SOLUTION:-$PROJECT.sln} %%G)
    pushv ARGS_LOOP 'for %%C in (Debug Release) do if /I "%1" == "%%C" ('${nl}'  set CONFIG=%%C'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv IF_TARGET 'if "%CONFIG%" == "" set CONFIG=Debug Release'
	case "$VCBUILDCMD" in
	  *vcbuild*)  pushv ARGS_LOOP 'for %%J in (clean rebuild) do if /I "%1" == "%%J" ('${nl}'  set ARGS= /%%J'${nl}'  shift'${nl}'  goto :args'${nl}')'  ;;
	  *)  pushv ARGS_LOOP 'for %%J in (clean rebuild) do if /I "%1" == "%%J" ('${nl}'  set ARGS= /t:%%J'${nl}'  shift'${nl}'  goto :args'${nl}')'  ;;
	esac
	ADD_ARGS=" %ARGS%"
	BUILD_TYPE="%CONFIG%"
	VCVARSCMD=$(vcget "${VC}-x64" VCVARSCMD )
	#VCVARSCMD=${VCVARSCMD/amd64/%ARCH%}
#	    echo "VCVARSCMD=$VCVARSCMD" 1>&2
#	    echo "VC=$VC" 1>&2
#	    echo "ARCH=$ARCH" 1>&2

	case "$VCBUILDCMD" in
	  *"
"*) VCBUILDCMD="(
$VCBUILDCMD
)" ;;
    esac
	
	if [ -e "$CL" ]; then
#      echo "Generating script $DIR/build.cmd ($(vcget "$VC" VCNAME))" 1>&2
      unix2dos >"$DIR/build.cmd" <<EOF
@echo ${BATCHECHO:-off}
%~d0
cd %~dp0
${ARGS_LOOP:+${nl}:args${nl}$ARGS_LOOP${nl}}${CONFIGURE_CMD:+${nl}$CONFIGURE_CMD${nl}}${IF_TARGET:+${nl}$IF_TARGET${nl}}${VCVARSCMD:+${nl}call $VCVARSCMD${nl}${BATCHECHO:+@echo $BATCHECHO${nl}}}
for %%G in (${BUILD_TYPE:-Debug Release}) do $VCBUILDCMD${ADD_ARGS}
rem ${INSTALL_CMD}
EOF
    fi) || exit $?
  done)
}

#!/bin/bash
 
#MYNAME=`basename "$0" .sh`
mk-list-index() {
 
: ${TEMP="c:/Temp"}

volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
      eval "$ECHO"
  done)
}

[ -n "$LIST_R64" ] && LIST_R64=$(cygpath -w "$LIST_R64")

{ 
  echo "@echo off
"
  if [ $# -le 0 ]; then
    if [ "$(uname -o)" = Cygwin ]; then
      set -- /cygdrive/?
    fi
    set -- $(volname  $(df -l "$@" | sed 1d |sort -nk3 |awk '{ print $6 }' ) |grep -viE '(ubuntu|fedora|UDF Volume|opensuse|VS201[0-9]|ext[234]|arch)'|sed 's,/.*,,')
  fi
  for D; do 
    P=$(cygpath "$D\\")

    N=$(volname "$P")
    W=${D//"/"/"\\"}
    W=${W##\\}
    echo "echo Indexing $D ($N)
${D%%/*}
cd \\${W#?:}
${LIST_R64:-list-r64} >files.tmp
del /f files.list
move files.tmp files.list
"
  done 
} |
unix2dos |
 (set -x; tee "E:/Temp/list-index.cmd" >/dev/null)

}

mkuuid() {
   printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM"
}

mkzroot()
{ 
    ( IFS="$IFS ";
    TEMPTAR=/tmp/mkzroot$$.tar;
    TEMPTXZ=${TEMPTAR%.tar}.txz;
    trap 'rm -vf "$TEMPTAR" "$TEMPTXZ"' EXIT INT QUIT;
    EXCLUDE="*~ *.tmp *mnt/* *.log *cache/*";
    CMD='tar --one-file-system --exclude={$(IFS=", $IFS"; set -f ; set -- $EXCLUDE;  echo "$*")} -C /root -cf "$TEMPTAR" .';
    CMD=$CMD'; xz -3 -vfc "$TEMPTAR" >"$TEMPTXZ"';
    eval "echo \"+ $CMD\" 1>&2";
    eval "$CMD";
    DEST=$(ls -d ` mountpoints /pmagic/pmodules ` 2>/dev/null);
    for DIR in $DEST;
    do
        ( CMD="cp --remove-destination -vf  \"\$TEMPTXZ\"  \"\$DIR/zroot.xz\"";
        eval "echo \"+ $CMD\" 1>&2";
        eval "$CMD" );
    done )
}

mminfo()
{
    ( for ARG in "$@";
    do
      ESC=${ARG//"&"/"\\&"}
        minfo "$ARG" | ${SED-sed} -n "s|^\([^:]*\):\s*\([^:]*\)\$|${2:+$ESC:}\1=\2|p";
    done | ${SED-sed} \
        's|\s\+=|=|  ;;
s|\([0-9]\) \([0-9]\)|\1\2|g
/Duration/ { 
  s|\([0-9]\) min|\1min|g
  s|\([0-9]\) \([hdw]\)|\1\2|g
  s|\([0-9]\) \(m\?s\)|\1\2|g
  s|\([0-9]\+\) \([^ ]*b/s\)$|\1\2|
}')
}

modules()
{
    local abs="no" ext="no" dir modules= IFS="
";
    require "fs";
    while :; do
        case $1 in
            -a)
                abs="yes"
            ;;
            -e)
                ext="yes"
            ;;
            -f)
                abs="yes" ext="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    if test "$abs" = yes; then
        fs_recurse "$@";
    else
        for dir in "${@-$shlibdir}";
        do
            ( cd "$dir" && fs_recurse );
        done;
    fi | {
        set --;
        while read module; do
            case $module in
                *.sh | *.bash)
                    if test "$ext" = no; then
                        module="${module%.*}";
                    fi;
                    if ! isin "$module" "$@"; then
                        set -- "$@" "$module";
                        echo "$module";
                    fi
                ;;
            esac;
        done
    }
}

mount-all()
{
    for ARG in "$@";
    do
        mount "$ARG" ${MNTOPTS:+-o
"$MNTOPTS"}
    done
}

mount-diskimage()
{ 
    IMG="$1";
		exec_cmd() {
			echo "+ $@" 1>&2 
			sudo "$@"
		}
    sfdisk -d "$IMG" | { 
        IFS=" ";
        : ${I:=1};
        while read DEV PART; do
            case "$PART" in 
                *start=*)
                    START=${PART##*start=};
                    START=${START%%,*};
                    START=$((START))
                ;;
							*) continue ;;
            esac;
            exec_cmd losetup -o $((START*512)) /dev/loop${I} "$1";
            MNT=/media/"${IMG##*/}-part1";
            exec_cmd mkdir -p "$MNT";
            exec_cmd mount /dev/loop${I} "$MNT";
        done
    }
}

mounted-devices() {
  (IFS=" "
  unset PREV
  while read -r DEV MNT FSTYPE OPTS A B; do
    case "$DEV" in
      rootfs | /dev/root) DEV=`get-rootfs` ;;
      /*) ;;
      *) continue	;;
    esac
    [ "$DEV" != "$PREV" ] && echo "$DEV"
    PREV="$DEV"
  done) </proc/mounts
}

mount-matching()
{
    ( MNTDIR="/mnt";
   [ "$UID" != 0 ] && SUDO=sudo
	 (list-devices-by || blkid) | grep-e "$@" | {
        IFS=" ";
        while read -r DEV PROPERTIES; do
            DEV=${DEV%:};
            unset LABEL UUID TYPE;
            eval "$PROPERTIES";
            MNT="$MNTDIR/${LABEL:-${DEV##*/}}";
            if ! is-mounted "$DEV" && ! is-mounted "$MNT"; then
                $SUDO mkdir -p "$MNT";
                echo "Mounting $DEV to $MNT ..." 1>&2;
                $SUDO mount "$DEV" "$MNT" ${MNTOPTS:+-o "$MNTOPTS"}
            fi;
        done
    } )
}

mountpoint-by-label() {
 (IFS="
 	"
  for MNT in $(wmic Path win32_volume where "Label='$1'" Get DriveLetter /format:list 2>&1); do
    case "$MNT" in
      DriveLetter=*)
        MNT=${MNT#DriveLetter=}
        MNT=${MNT:0:1}:
        break
      ;;
    esac
  done
  [ -n "$MNT" ] && { echo "$MNT" | tr "[:"{upper,lower}":]"; })
} ||

mountpoint-by-label() {
 (if [ -e /dev/disks/by-label/"$1" ]; then
    mountpoint-for-device "$1"
  else
    DEV=$(blkid -L "$1")
    if [ -n "$DEV" -a -e "$DEV" ]; then
      mountpoint-for-device "$DEV"
    fi
  fi)
}

mountpoint-for-device()
{
    ( set -- $(${GREP-grep} "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}

mountpoint-for-file() {
  case `uname -o` in
    Msys*) (abspath=$(cygpath -am "$1"); drive=${abspath%%:*}:; cygpath -a "$drive") ;;
    *) (df "$1" | ${SED-sed} 1d | awkp 6)  ;;
  esac
}

mountpoints()
{
    ( while :; do
        case "$1" in
            -u | --user)
                USER=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    function lsmnt()
    {
        if [ -e /proc/mounts ]; then
            awk '{ print $2'"${1:+.\"/${1#/}\"} }" /proc/mounts;
        else
            if type df 2> /dev/null > /dev/null; then
                :;
            else
                ( IFS=" ";
                mount | while read -r DRIVE ON MNT TYPE USER OPTS; do
                    if [ -n "$MNT" -a -d "$MNT" ]; then
                        echo "$MNT${1:+/${1#/}}$";
                    fi;
                done );
            fi;
        fi
    };
    CMD="lsmnt \"\$@\"";
    [ "$USER" = true ] && CMD="$CMD | ${GREP-grep} -vE '^(/\$|/proc|/sys|/dev)'";
    eval "$CMD" )
}

mount-remaining()
{
    ( MNT="${1:-/mnt}";
    [ "$UID" != 0 ] && SUDO=sudo
    for DEV in $(not-mounted-disks); do
        LABEL=` disk-label "$DEV"`
        TYPE=` blkvars "$DEV" TYPE`
        case "$TYPE" in
          swap) continue ;;
        esac
        MNTDIR="$MNT/${LABEL:-${DEV##*/}}"
        $SUDO mkdir -p "$MNTDIR";
        echo "Mounting $DEV to $MNTDIR ..." 1>&2
        $SUDO mount "$DEV" "$MNTDIR" ${MNTOPTS:+-o
"$MNTOPTS"};
    done )
}

msgbegin()
{
    echo -n "${me:+$me: }$@" 1>&2
}

msgcontinue()
{
    echo -n "$@" 1>&2
}

msgend()
{
    echo "$@" 1>&2
}

msiexec()
{
    ( IFS="
";
    IFS=" $IFS";
    while :; do
        case "$1" in
            -*)
                ARGS="${ARGS+
}/${1#-}";
                shift
            ;;
            /?)
                ARGS="${ARGS+
}${1}";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    "$COMSPEC" "/C" "${MSIEXEC} $ARGS $(msyspath -w "$@")" )
}

msleep()
{
    local sec=$((${1:-0} / 1000)) msec=$((${1:-0} % 1000));
    while [ "${#msec}" -lt 3 ]; do
        msec="0$msec";
    done;
    sleep $((sec)).$msec
}

_msyspath()
{
 (add_to_script() { while [ "$1" ]; do SCRIPT="${SCRIPT:+$SCRIPT ;; }$1"; shift; done; }

  case $MODE in
    win*|mix*) #add_to_script "s|^${SYSDRIVE}[\\\\/]\(.\)[\\\\/]|\1:/|" "s|^${SYSDRIVE}[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
      add_to_script "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\\([\\\\/]\\)\\([^\\\\/]\\)\\?|\\1:\\2\\3|" "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\$|\\1:/|" ;;
    *) add_to_script "s|^\([A-Za-z0-9]\):|${SYSDRIVE}/\\1|" ;;
  esac
  case $MODE in
    win*|mix*)
      for MOUNT in $(mount | ${SED-sed} -n 's|\\|\\\\|g ;; s,\(.\):\\\(.\+\) on \(.*\) type .*,\1:\\\2|\3,p'); do
        DEV=${MOUNT%'|'*}
        MNT=${MOUNT##*'|'}
        test "$MNT" = / && DEV="$DEV\\\\"

        add_to_script "/^.:/! s|^${MNT}|${DEV}|"
       done

       #ROOT=$(mount | ${SED-sed} -n 's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      #add_to_script "/^.:/!  s|^|$ROOT|"
    ;;
  esac
  case "$MODE" in
    win32) add_to_script "s|/|\\\\|g" ;;
    *) add_to_script "s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) add_to_script "s|^${SYSDRIVE}/A/|${SYSDRIVE}/a/|" "s|^${SYSDRIVE}/B/|${SYSDRIVE}/b/|" "s|^${SYSDRIVE}/C/|${SYSDRIVE}/c/|" "s|^${SYSDRIVE}/D/|${SYSDRIVE}/d/|" "s|^${SYSDRIVE}/E/|${SYSDRIVE}/e/|" "s|^${SYSDRIVE}/F/|${SYSDRIVE}/f/|" "s|^${SYSDRIVE}/G/|${SYSDRIVE}/g/|" "s|^${SYSDRIVE}/H/|${SYSDRIVE}/h/|" "s|^${SYSDRIVE}/I/|${SYSDRIVE}/i/|" "s|^${SYSDRIVE}/J/|${SYSDRIVE}/j/|" "s|^${SYSDRIVE}/K/|${SYSDRIVE}/k/|" "s|^${SYSDRIVE}/L/|${SYSDRIVE}/l/|" "s|^${SYSDRIVE}/M/|${SYSDRIVE}/m/|" "s|^${SYSDRIVE}/N/|${SYSDRIVE}/n/|" "s|^${SYSDRIVE}/O/|${SYSDRIVE}/o/|" "s|^${SYSDRIVE}/P/|${SYSDRIVE}/p/|" "s|^${SYSDRIVE}/Q/|${SYSDRIVE}/q/|" "s|^${SYSDRIVE}/R/|${SYSDRIVE}/r/|" "s|^${SYSDRIVE}/S/|${SYSDRIVE}/s/|" "s|^${SYSDRIVE}/T/|${SYSDRIVE}/t/|" "s|^${SYSDRIVE}/U/|${SYSDRIVE}/u/|" "s|^${SYSDRIVE}/V/|${SYSDRIVE}/v/|" "s|^${SYSDRIVE}/W/|${SYSDRIVE}/w/|" "s|^${SYSDRIVE}/X/|${SYSDRIVE}/x/|" "s|^${SYSDRIVE}/Y/|${SYSDRIVE}/y/|" "s|^${SYSDRIVE}/Z/|${SYSDRIVE}/z/|"
    ;;
    win*)  add_to_script "s|^a:|A:|" "s|^b:|B:|" "s|^c:|C:|" "s|^d:|D:|" "s|^e:|E:|" "s|^f:|F:|" "s|^g:|G:|" "s|^h:|H:|" "s|^i:|I:|" "s|^j:|J:|" "s|^k:|K:|" "s|^l:|L:|" "s|^m:|M:|" "s|^n:|N:|" "s|^o:|O:|" "s|^p:|P:|" "s|^q:|Q:|" "s|^r:|R:|" "s|^s:|S:|" "s|^t:|T:|" "s|^u:|U:|" "s|^v:|V:|" "s|^w:|W:|" "s|^x:|X:|" "s|^y:|Y:|" "s|^z:|Z:|" ;;
  esac
  #echo "SCRIPT=$SCRIPT" 1>&2
 (${SED-sed} "$SCRIPT" "$@")
 )
}

msyspath()
{
 (MODE=msys
  while :; do
    case "$1" in
      -w) MODE=win32; shift ;;
      -m) MODE=mixed; shift ;;
      *) break ;;
    esac
  done
  CMD=_msyspath
  if [ "$1" != "-" -a "$#" -gt 0 ]; then
    CMD="echo \"\$*\" |$CMD"
  fi
  eval "$CMD"
  exit $?)
}

multiline-list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}

multiply-num() {
 (for ARG; do
    case "$ARG" in
      *[0-9].* | *.[0-9]*) CMD='$(bc -l <<\EOF
'$ARG'
EOF
)'  ;;
      *) CMD='$(( '$ARG' ))' ;;
    esac
    eval "N=$CMD"
    case "$N" in
      .*) N="0$N" ;;
      *.*0) while [ "$N" != "${N%0}" ]; do N=${N%0}; done ;;
    esac
    echo "${N%.}"
  done)
}

multiply-resolution()
{
    ( WIDTH=${1%%x*};
    HEIGHT=${1#*x};
    echo $((WIDTH * $2))x$((HEIGHT * $2)) )
}

myip()
{
    ( IFS=" " e_ip="[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" e_nn="[^0-9]*";
    for host in ${@:-$INET_getip_hosts};
    do
        msg "Checking $host...";
        myip=$(curl -s --socks5 127.0.0.1:9050 "$host" |
         ${SED-sed} -n -e "/${e_nn}127.0.0.1${e_nn}/ d"                   -e "/${e_nn}192.168\./ d"                   -e "/${e_nn}10\./ d"                   -e "/$e_ip/ {
                      s|^${e_nn}\\($e_ip\\)${e_nn}\$|\\1|
                      p
                      q
                    }");
        if ip4_valid "$myip"; then
            echo "$myip";
            exit 0;
        fi;
    done;
    exit 1 )
}

myrealpath()
{
 (for ARG; do
    DIR=` dirname "$ARG" `;
    BASE=` basename "$ARG" `;
    cd "$DIR";
    if [ -h "$BASE" ]; then
    FILE=` readlink "$BASE"`;
    fi;
    DIR=` dirname "$FILE"`;
    BASE=`basename "$FILE"`;
    if is-relative "$ARG"; then
    DIR="$PWD/$DIR";
    fi;
    DIR=$(cd "$DIR"; pwd -P);
    echo "$DIR/$BASE"
  done)
}

neighbours()
{
    while test "${2+set}" = set; do
        echo "$1" ${2+"$2"};
        shift;
    done
}

notice()
{
    msg "NOTICE: $@"
}

not-mounted-disks()
{
    ( IFS="
";
    for DISK in $(all-disks);
    do
        is-mounted "$DISK" || echo "$DISK";
    done )
}

ntfs-get-uuid()
{
    ( IFS=" ";
    set -- $(  dd if="$1" bs=1 skip=$((0x48)) count=8 |hexdump -C -n8);
    IFS="";
    echo "${*:2:8}" )
}

num-suffix()
{ 
    ( for N in "$@";
    do
        if [ "$N" -ge 1099511627776 ]; then
            N=$(multiply-num "$N / 1099511627776")P;
        else
            if [ "$N" -ge 1073741824 ]; then
                N=$(multiply-num "$N / 1073741824")G;
            else
                if [ "$N" -ge 1048576 ]; then
                    N=$(multiply-num "$N / 1048576")M;
                else
                    if [ "$N" -ge 1024 ]; then
                        N=$(multiply-num "$N / 1024")K;
                    fi;
                fi;
            fi;
        fi;
        echo "$N";
    done )
}

output-boot-entry()
{
 (
  [ -z "$FORMAT" ] && FORMAT="$1"
  case "$FORMAT" in
    grub4dos)
       echo "title "${TITLE//"
"/"\\n"}
         [ "$CMDS" ] && echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS"| ${SED-sed} 's,^,#,'
       if [ "$KERNEL" ]; then
        echo "kernel $KERNEL"
       [ "$INITRD" ] && echo "initrd $INITRD"
       fi

    ;;
    grub2)
       echo "menuentry \"$TITLE\" {"
       echo "  linux${EFI} $KERNEL"
       echo "  initrd${EFI} $INITRD"
       echo "}"
    ;;
    syslinux|isolinux)
       #[ -z "$LABEL" ] && 
       
       LABEL=$(canonicalize -m 16 -l "${TITLE//PartedMagic/pmagic}")
       echo "label $LABEL"
       echo "  menu label ${TITLE%%
*}"
       if [ "$KERNEL" ]; then
         set -- $KERNEL
         echo "  kernel ${1%%" "*}"
         args=${1#*" "}
         shift
         [ "$INITRD" ] && set -- initrd="$INITRD" "$@"
         [ $# -gt 0 ] &&
         echo "  append" $args $@
       fi

       if [ "$CMDS" ]; then
         echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS" |${SED-sed} 's,^,  #,'
         fi

     ;;
  esac
  echo
 )
}

output-mingwvars() {
 (: ${O=${1:+$1/}mingwvars.cmd}
 echo "Outputting '${O//$FS/$BS}'..." 1>&2
 case "$O" in
   *.cmd | *.bat)
	cat <<EOF | unix2dos >"$O"
@echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
if "%1" == "" goto end
cd "%1"
:end
echo Variables are set up for "${SUBDIRNAME}"
EOF
     ;;
   *.sh | *.bash)
     cat <<EOF >"$O"
#!/bin/sh
PATH="\${_}${SUBDIRNAME}:\${_}${SUBDIRNAME}/bin:\$PATH"
echo "Variables are set up for ${SUBDIRNAME}" 1>&2
EOF
    ;;
  esac
)
}

output-startmingwprompt() {
 (: ${O=${1:+$1/}start-mingw-prompt.bat}
 echo "Outputting '${O//$FS/$BS}'..." 1>&2
  cat <<EOF | unix2dos >"$O"
@echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
rem echo %PATH%
rem cd "%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin"
cd "%~dp0"
if "%1" == "" goto end
cd "%1"
:end
cmd.exe /k "call %~dp0mingwvars.cmd"
EOF
)
}

packed-upx-files()
{
    upx -l "$@" 2>&1 | ${SED-sed} -n '$ { \,files\s*\]$,d } ;; $! { \,->, s,.*->\s\+[0-9]\+\s\+[.0-9]\+%\s\+[^ ]\+\s\+\(.*\),\1,p }'
}

parent-file() {
 (recurse() {
    FN=${1##*/}
    DIR=${1%/*}
    while ! [ "$DIR" -ef "$DIR/.." ]
    do
     PARENT=$(cd "$DIR/.." && pwd)
        [ -e "$PARENT/$FN" ] && DIR=$PARENT || break
      echo "PWD: ${PWD}" 1>&2
   done
    if [ -e "$DIR/$FN" ]; then
      return 0
    fi
    return 1
  }

  while [ $# -gt 0 ]; do
     recurse "$1"
     echo "$DIR/$FN"
     shift
  done)
}

parse-boot-entry()
{
  clear-boot-entry() {  TYPE= LABEL= TITLE= KERNEL= INITRD= CMDS=; }
   NL="
"
  unset LINEBUF

  getline()
  {
    if [ -n "$LINEBUF" ]; then
      LINE="${LINEBUF%%$NL*}"
      case "$LINE" in
        EOF\ *) T=; clear-boot-entry; return 1 ;;
        *) LINEBUF=${LINEBUF#"$LINE"}; LINEBUF=${LINEBUF#"$NL"} ;;
        esac
    else
      if ! read -r LINE; then
        LINE=""
        LINEBUF="${LINEBUF:+$LINEBUF$NL}EOF $?"
        return 0
      fi
    fi
    OLDIFS="$IFS"
    IFS=" "
    set -- $LINE
    CMD=$(echo "$1" | tr "[:upper:]" "[:lower:]")
    shift
    ARG="$*"
    IFS="$OLDIFS"
  }
  ungetline() { LINEBUF="$LINE${LINEBUF:+$NL$LINEBUF}"; }

  while :; do
    getline || return $?
    while [ "$LINE" != "${LINE#' '}" ]; do LINE=${LINE#' '}; done
    [ -z "$LINE" -a -n "$TYPE" ] && return 0
    [ -z "$CMD" ] && continue
    if [ -z "$T"  ]; then
      clear-boot-entry
      case "$CMD" in
        menuentry) T=grub; TITLE=${LINE#*\"}; TITLE=${TITLE%\"*\{} ;;
        title) T=oldgrub; TITLE=${ARG}; TITLE=${TITLE//"\\n"/"$NL"} ;;
        label) T=syslinux LABEL=${ARG} ;;
#	      menu | *MENU*LABEL*) T=syslinux; TITLE=${LINE#*MENU}; TITLE=${TITLE#*LABEL}; TITLE=${TITLE#*label}; TITLE=${TITLE/^/} ;;
        *) continue ;;
      esac
      LABEL=${LABEL#' '}
      TITLE=${TITLE#' '}
    else
    TYPE="$T"
    ARG=${ARG//"\\n"/"$NL"}
    echo "+ CMD=$CMD ARG=$ARG" 1>&2
      case "$T" in
         syslinux)
            case "$CMD" in
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel\ }" ;;
              append)
                 IFS="$IFS "
                 set -- ${LINE#*append\ }
                 for ARG; do
                   case "$ARG" in
                     initrd=*) INITRD="${ARG#*=}" ;;
                     *) KERNEL="${KERNEL:+$KERNEL }$ARG" ;;
                   esac
                 done
                  ;;
              menu)  ARG=${ARG/^/}; TITLE="${TITLE:+$TITLE$NL}${ARG}" ;;
              label)  ungetline; unset T; return 0 ;;
           *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;

            esac
         ;;
         grub)
            case "$CMD" in
               '#'*) continue ;;
              linux) KERNEL="${LINE#*linux*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              chainloader|  configfile) CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              menuentry) ungetline; unset T; return 0 ;;
              *)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
            esac
         ;;
         oldgrub)
            case "$CMD" in
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              #map*|find*|chainloader*|root*|configfile*|set*|cat*|timeout*|default*|rootnoverify*|savedefault*|terminal*|fallback*|echo*|color*|lock*|write*|splashimage*|iftitle*|graphicsmode*|calc*|menu*|found*)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              title*) ungetline; unset T; return 0 ;;
              *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
            esac
         ;;
       esac
      fi
  done
}

partition-table-type()
{
    ( if command-exists "parted"; then
        parted "$1" p | ${SED-sed} -n 's,.*Table:\s\+,,p';
    else
        ( eval "$(  gdisk -l "$(disk-device-for-partition "$1")" |${SED-sed} 's,\s*not present$,,' |${SED-sed} -n  's,^\s*\([[:upper:]]\+\):\(\s*\)\(.*\),\1="\3",p')";
        if [ "$MBR" -a "$GPT" ]; then
            echo "mbr+gpt";
        else
            if [ "$MBR" ]; then
                echo "mbr";
            else
                if [ "$GPT" ]; then
                    echo "gpt";
                fi;
            fi;
        fi );
    fi )
}

path-executables()
{
    ( IFS=":;";
    for DIR in $PATH;
    do
        ( cd "$DIR";
        for FILE in *;
        do
            test -f "$FILE" -a -x "$FILE" && echo "$FILE";
        done );
    done ) 2> /dev/null
}

pathmunge() { 
  if [ -e /bin/grep ]; then
     GREP=/bin/grep
  else
    GREP=/usr/bin/grep
  fi
  while :; do
    case "$1" in -s) PATHSEP="$2"; shift 2 ;;
		-v) PATHVAR="$2"; shift 2 ;;
		-e) EXPORT="export "; shift ;;
		-f) FORCE=true; shift ;;
		-a) AFTER=true; shift ;;
		*) break ;;
		esac
    done
    : ${PATHVAR=PATH}
    local IFS=":"
    : ${OS=`uname -o | head -n1`}
    case "$OS:$1" in
	  [Mm]sys:*[:\\]*) tmp="$1"; shift; set -- `${PATHTOOL:-msyspath} "$tmp"` "$@" ;;
    esac
    IFS=" "
    FXPR="(^|${PATHSEP-:})$1($|${PATHSEP-:})"
    if ! eval "echo \"\${${PATHVAR}}\" | $GREP -E -q \"\$FXPR\""; then
	  if [ "$2" = after -o "$AFTER" = true ]
		then CMD="${EXPORT}${PATHVAR}=\"\${${PATHVAR}:+\$${PATHVAR}${PATHSEP-:}}\$1\""
		else CMD="${EXPORT}${PATHVAR}=\"\$1\${${PATHVAR}:+${PATHSEP-:}\$${PATHVAR}}\""
	  fi
    fi
    [ "$FORCE" = true ] && CMD="pathremove \"$1\"
    $CMD"
#    eval "CMD=\"${CMD//\""
    [ "$DEBUG" = true ] && eval "echo \"+ $CMD\" 1>&2"
    eval "$CMD"
    unset PATHVAR
 }

pathremove() { old_IFS="$IFS"; IFS=":"; RET=1; unset NEWPATH; for DIR in $PATH; do for ARG in "$@"; do case "$DIR" in $ARG) RET=0; continue 2 ;; esac; done; NEWPATH="${NEWPATH+$NEWPATH:}$DIR"; done; PATH="$NEWPATH"; IFS="$old_IFS"; unset NEWPATH old_IFS; return $RET; }

type pathtool >/dev/null 2>/dev/null || pathtool() {
 (EXPR= F=
  while :; do
    case "$1" in
      -w | -m | -u) F="$1"; shift ;;
      *) break ;
    esac
  done
  [ $# -gt 0 ] && exec <<<"$*"

  case "$F" in
    -w | -m) ROOTS=$(mount | ${SED-sed} -n '\|/cygdrive|! s,^\([^ ]*\) on \(.*\) type.*,\\|^.:|! { \\|^/cygdrive|! { s|^\2|\1| } };,p') ;;
    *) ROOTS=$( mount  | ${SED-sed} -n '\|/cygdrive|! s,^\([^ ]*\) on \(.*\) type.*,\1\n\2,p' | ${SED-sed} '/^.:/ { s|/|\[\\\\/\]|g; N; s,\n,|, ; s,.*,s|^&|; , }') ;;
  esac

  EXPR="${EXPR:+$EXPR ;; }$ROOTS"

  case "$F" in
	-w | -m) EXPR="${EXPR:+$EXPR ;; }s|/cygdrive/\(.\)/\(.*\)|\1:/\2|" ;;
	*) EXPR="${EXPR:+$EXPR ;; }s|^\(.\):|/cygdrive/\1|" ;;
  esac


  case "$F" in
	-m | -u) EXPR="${EXPR:+$EXPR ;; }s|\\\\|/|g" ;;
	-w) EXPR="${EXPR:+$EXPR ;; }s|/|\\\\|g" ;;
  esac

  [ "$DEBUG" = true ] && echo "+ ${SED-sed} '$EXPR'"
  ${SED-sed} "$EXPR")
}

pdfpages()
{ 
    while [ $# -gt 0 ]; do
        pdfinfo "$1" | info_get Pages | addprefix "$1: ";
        shift;
    done
}

pdfpextr()
{
(FIRST=$(($1)) LAST=$(($2))
    # this function uses 3 arguments:
    #     $1 is the first page of the range to extract
    #     $2 is the last page of the range to extract
    #     $3 is the input file
    #     output file will be named "inputfile_pXX-pYY.pdf"
    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage="$FIRST" \
       -dLastPage="$LAST" \
       -sOutputFile=${3%.[Pp][Dd][Ff]}_p"$FIRST"-p"$LAST".pdf \
       "${3}"
    )
}

pid-args()
{
  pid-of "$@" | ${SED-sed} -n  "/^[0-9]\+$/ s,^,-p\n,p"
}

pid-of() {
 (: ${GREP=grep
-a}
  if handle -h 2>&1 |grep -q '\-a'; then
     PGREP_CMD="handle -a | $GREP -i \"\$ARG.*pid:\" | awkp 3"
  elif ps --help 2>&1 | $GREP -q '\-W'; then
     PGREP_CMD="ps -aW | $GREP -i \"\$ARG\" | awkp"
  elif type pgrep 2>/dev/null >/dev/null; then
     PGREP_CMD='pgrep -f "$ARG"'
  else
     PGREP_CMD="ps -ax | $GREP -i \"\$ARG\" | awkp"
  fi
  for ARG in "$@"; do
    eval "$PGREP_CMD"
  done | ${SED-sed} -n 's/^\([0-9]\+\)\r\?$/\1/p')
}

pkginst()
{
    ( PKGS=`pkgsearch "$@"`;
    set -- ${PKGS%%" "*};
    if [ $# -gt 0 ]; then
        sudo yum -y install "$@";
    fi )
}

pkg-name()
{
    ( for ARG in "$@";
    do
        ARG=${ARG%.t?z};
        ARG=${ARG%.[tdr][aegpx][rbmz]*};
        ARG=${ARG%.*};
        echo "${ARG%%-[0-9]*}";
    done )
}

pkgsearch()
{
    ( EXCLUDE='-common -data -debug -doc -docs -el -examples -fonts -javadoc -static -tests -theme';
    for ARG in "$@";
    do
        sudo yum -y search "${ARG%%[!-A-Za-z0-9]*}" | ${GREP-grep} -i "$ARG[^ ]* : ";
    done | ${SED-sed} -n "/^[^ ]/ s,\..* : , : ,p" | ${GREP-grep} -vE "($(IFS='| '; set -- $EXCLUDE; echo "$*"))" | uniq )
}

player-file()
{
  ( SED_SCRIPT=
  while :; do
          case "$1" in
                  -H|--no*hidden) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|/\\.|d" ; shift ;;
                  -P|--no*proc) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^/proc|d" ; shift ;;
          -x|--exclude) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|${2//*/.*}|d" ; shift 2  ;;
          -x=*|--exclude=*) P=${1#*=}; SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^"${P//"*"/".*"}"\$|d" ; shift   ;;
          *) break ;;
          esac
  done
  SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }s| ([^)]*)\$||"
    lsof -n $(pid-args "${@-mplayer}") 2> /dev/null 2> /dev/null 2> /dev/null 2> /dev/null | ${GREP-grep}  -E ' [0-9]+[^ ]* +REG ' | ${GREP-grep
-a
--line-buffered
--color=auto} -vE ' (mem|txt|DEL) ' | cut-lsof NAME |${SED-sed} "$SED_SCRIPT" )
}

port-joinlines() { 
  ${SED-sed} -n '/ @/ {
    :lp
    /\n *$/! { N; b lp; }
    s|\n| - |g
    s|[- ]*$||; p
  }'
}

proc-by-pid() {
  if ps --help 2>&1 |${GREP-grep} -q '\-W'; then
    PSARGS="-W"
  fi
  for ARG; do
     ps $PSARGS -p "$ARG" | ${SED-sed} 1d
  done |cut-ls-l 7
}

proc-mount()
{
    for ARG in "$@";
    do
        ( ${GREP-grep} "^$ARG" /proc/mounts );
    done
}

prof()
{
    PROF="$HOME/.bash_profile";
    case "$1" in
        load* | source* | relo*)
            . "$PROF"
        ;;
        edit)
            "${2:-$EDITOR}" "$(${PATHTOOL:-echo} "$PROF")"
        ;;
    esac
}

pushv() {
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

pushv-unique()
{
    local v=$1 s IFS=${IFS%${IFS#?}};
    shift;
    for s in "$@";
    do
        if eval "! isin \$s \${$v}"; then
            pushv "$v" "$s";
        else
            return 1;
        fi;
    done
}

quiet()
{
    "$@" 2> /dev/null
}

quote() {  (unset O; SQ="'"; DQ='"'; BS="\\"
  for A; do case "$A" in
      *\ * | *[\|\(\)]*) O="${O+$O }'${A//"$SQ"/"$SQ$BS$SQ$SQ"}'" ;;
      *)  A=${A//"$SQ"/"$BS$SQ"}; A=${A//"$DQ"/"$BS$DQ"}; O="${O+$O } $A" ;;

    esac; done; echo "$O")
  }

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
rand-mac-addr() {
 hexdump -C /dev/urandom|cut-hexnum |cut -d' ' -f1,2,3,4,5,6|sed 's, ,:,g'|head -n1
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
rand()
{
    local rot=$(( ${random_seed:-0xdeadbeef} & 0x1f ));
    local xor=`expr ${random_seed:-0xdeadbeef} \* (${random_seed:-0xdeadbeef} "<<" $rot)`;
    random_seed=$(( ( $(bitrotate "${random_seed:-0xdeadbeef}" "$rot") ^ $xor) & 0xffffffff ));
    expr "$random_seed" % ${1:-4294967296}
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
randhex()
{
    for n in $(seq 1 ${1:-16});
    do
        printf "${2:-0x}%02x\n" $((RANDOM % 256 ));
    done
}

rand-mac-addr() {
 hexdump -C /dev/urandom|cut-hexnum |cut -d' ' -f1,2,3,4,5,6|sed 's, ,:,g'|head -n1
}

random-acquire()
{
    local n IFS="$newline";
    for n in $(echo "$@" | hexdump -d | ${SED-sed} "s,^[0-9a-f]\+\s*,,;s,\s\+,\n,g");
    do
        local rot=$(( (${random_seed:-0xdeadbeef} + (n >> 11)) & 0x1f)) xor=$((${random_seed:-0xdeadbeef} - (n & 0x07ff)));
        random_seed=$(( ($(bitrotate $(( ${random_seed:-0xdeadbeef} )) $rot) ^ $xor) & 0xffffffff ));
    done;
    echo "seed: ${random_seed:-0xdeadbeef}"
}

rand()
{
    local rot=$(( ${random_seed:-0xdeadbeef} & 0x1f ));
    local xor=`expr ${random_seed:-0xdeadbeef} \* (${random_seed:-0xdeadbeef} "<<" $rot)`;
    random_seed=$(( ( $(bitrotate "${random_seed:-0xdeadbeef}" "$rot") ^ $xor) & 0xffffffff ));
    expr "$random_seed" % ${1:-4294967296}
}

rangearg()
{
    ( S="$1";
    E="$2";
    shift 2;
    eval set -- "\${@:$S:$E}";
    echo "$*" )
}

regexp-to-fnmatch()
{
    ( expr=$1;
    case $expr in
        '^'*)
            expr="${expr#^}"
        ;;
        *)
            expr="*${expr}"
        ;;
    esac;
    case $expr in
        *'$')
            expr="${expr%$}"
        ;;
        '*')

        ;;
        *)
            expr="${expr}*"
        ;;
    esac;
    case $expr in
        *'.*'*)
            expr=`echo "$expr" | ${SED-sed} "s,\.\*,\*,g"`
        ;;
    esac;
    case $expr in
        *'.'*)
            expr=`echo "$expr" | ${SED-sed} "s,\.,\?,g"`
        ;;
    esac;
    echo "$expr" )
}

reload()
{
    local script retcode var force="no";
    while :; do
        case $1 in
            -f)
                force="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    script=$(require -p -n ${1%.sh});
    name=${script%.sh}_sh;
    var=$(echo lib/$name | ${SED-sed} -e s,/,_,g);
    if test "$force" = yes; then
        verbose "Forcing reload of $script";
        local fn;
        for fn in $(${SED-sed} -n -e 's/^\([_a-z][_0-9a-z]*\)().*/\1/p' $shlibdir/$script);
        do
            case $fn in
                require | verbose | msg)
                    continue
                ;;
            esac;
            verbose "unset -f $fn";
            unset -f $fn;
        done;
    fi;
    verbose "unset $var";
    unset "$var";
    verbose "require $script";
    source "$shlibdir/$script"
}

remove-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | ${SED-sed} 's,[/.],_,g' | tr '[[:'{lower,upper}':]]')

  ${SED-sed} -i "\\|^\s*#\s*if[^\n]*def[^\n]*$INCDEF| {
    :lp
    /#\s*endif/! { N; b lp; }

   s|^\s*#\s*if[^\n]*def[^\n]*$INCDEF[^\n]*\n||
   s|[^\n]*#[^\n]*endif[^\n]*$||
  }" "$@"

  )
}

remove-emptylines()
{
    ${SED-sed} -e '/^\s*$/d' "$@"
}

removeprefix()
{
 (PREFIX=$1; shift
  CMD='echo "${LINE#$PREFIX}"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}

removesuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "${LINE%$SUFFIX}"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}

resolution() {
 (EXPR='/Width/N
/pixels/ {
  s|Width=\([0-9]\+\)\s*pixels| \1|g
  s|Height=\([0-9]\+\)\s*pixels| \1|g
  s|[^\n]*:\s\+\([^\n:]*\)$|\1|
  s|\r\n|\n|g
  s| *\n *|x|p
}'; while [ $# -gt 0 ] ; do case "$1" in
    -m | --mult*) CMD="echo \$(($1 * $2))"; shift ;; 
    *) break ;;
  esac
  done
  mminfo "$@"|${SED-sed} -n "$EXPR")
}                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                     

retcode()
{
    "$@";
    msg "\$? = $?"
}

reverse()
{
    ( INDEX=$#;
    while [ "$INDEX" -gt 0 ]; do
        eval "echo \"\${$INDEX}\"";
        INDEX=`expr $INDEX - 1`;
    done )
}

rgb()
{
    ( c=${1#'#'};
    r=$(( 0x${c:0:2} ));
    g=$(( 0x${c:2:2} ));
    b=$(( 0x${c:4:2} ));
    [ "${c:6:2}" ] && a=$(( 0x${c:6:2} )) || a=;
    case "$2" in
        r)
            echo $((r))
        ;;
        g)
            echo $((g))
        ;;
        b)
            echo $((b))
        ;;
        a)
            echo $((a))
        ;;
        y)
            echo $(( (($r + $g + $b) + 2) / 3 ))
        ;;
        yuv)
            y=$(( ((66*${r}+129*${g}+25*${b}+128)>>8)+16 ));
            u=$(( ((-38*${r}-74*${g}+112*${b}+128)>>8)+128 ));
            v=$(( ((112*${r}-94*${g}-18*${b}+128)>>8)+128 ));
            echo $y $u $v
        ;;
        hsl)
            min=$(min $r $g $b);
            max=$(max $r $g $b);
            if [ ! "$min" -eq "$max" ]; then
                if [ "$r" -eq "$max" -a "$g" -ge "$b" ]; then
                    h=$(( (g-b)*85/(max-min)/2 ));
                else
                    if [ "$r" -eq "$max" -a "$g" -lt "$b" ]; then
                        h=$(( (g-b)*85/(max-min)/2+255 ));
                    else
                        if [ "$g" -eq "$max" ]; then
                            h=$(( (b-r)*85/(max-min)/2+85 ));
                        fi;
                    fi;
                fi;
            fi;
            l=$(( (min+max) / 2 ));
            if [ "$min" -eq "$max" ]; then
                s=0;
            else
                if [ "$((min+max))" -lt 256 ]; then
                    s=$(( (max-min)*256/(min+max) ));
                else
                    s=$(( (max-min)*256/(512-min-max) ));
                fi;
            fi;
            echo $h $s $l
        ;;
        *)
            echo $(($r)) $(($g)) $(($b)) ${a:+$(($a))}
        ;;
    esac )
}

rm-arch()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    ${SED-sed} 's,\.[^\.]*$,,' )
}

rmv()
{
    "${COMMAND-command}" rsync -r --remove-source-files -v --partial --size-only --inplace -D --links "$@"
}

rm-ver()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    ${SED-sed} 's,-[^-]*$,,' )
}

rpm-cmd() {
  OPTS= OUTPUT=
  while :; do
    case "$1" in
      -o) OUTPUT="$2"; shift 2 ;; -o*) OUTPUT="${1#-o}"; shift  ;; --output=*) OUTPUT="${1#*=}"; shift  ;;
      -*) OPTS="${OPTS:+$OPTS$IFS}$1"; shift ;;
      --) shift; break ;;
      *) break ;;
    esac
  done

 #CMD="addprefix \"\$ARG: \""
 CMD="${SED-sed} \"s|^\\./|| ;; s|^|\$ARG: |\""
 #N=$#

  while [ $# -gt 0 ]; do
    ARG="$1"
    shift
   (case "$ARG" in
      #*://*) DLCMD="wget -q -O - \"\$ARG\" | rpm2cpio /dev/stdin" ;;
      #*://*) DLCMD="lynx -source \"\$ARG\" | rpm2cpio /dev/stdin" ;;
      #*://*) DLCMD="lynx -source \"\$ARG\" | rpm2cpio /dev/stdin" ;;
    *://*)
      MIRRORLIST=`curl -s "$ARG.mirrorlist" |${SED-sed} -n 's,\s*<li><a href="\([^"]*\.rpm\)">.*,\1,p'`

      if [ -n "$MIRRORLIST" ]; then
        set -- $MIRRORLIST
      else
        set -- "$ARG"
      fi
      DLCMD='wget -q -O - "$1" | rpm2cpio /dev/stdin'
      ;;
      *) set -- "$ARG"
        DLCMD='rpm2cpio "$ARG"'
        ;;
    esac
    CMD="$DLCMD | (${OUTPUT:+cd \"\$OUTPUT\"; }cpio \${OPTS:--t} 2>/dev/null)${CMD:+ | $CMD}"
    while [ $# -gt 0 ]; do
      eval "( $CMD ) 2>/dev/null" && exit 0
      #echo continue 1>&2
      shift
    done

    echo "Failed to list $ARG" 1>&2
    exit 1)
  done
}

rpm-extract() {
  rpm-cmd -i -d -u -- "$@"
}

rpm-list() {
  rpm-cmd -t -- "$@"
}

samplerate()
{
  ( N=$#
  for ARG in "$@";
  do
		EXPR='/^Sampling rate/ { s,^[^:]*:\s*,,; p }'
    test $N -le 1 && P="" || P="$ARG:"

		HZ=$(mediainfo "$ARG" | sed -n "$EXPR")

		case "$HZ" in
			*KHz) HZ=$(echo "${HZ% KHz} * 1000" | bc -l| sed 's,\.0*$,,') ;;
		  *Hz) HZ=$(echo "${HZ% Hz}" | sed 's, ,,g') ;;
		esac	
		echo "$P$HZ" 
	done)
}

scriptdir()
{
    local absdir reldir thisdir="`pwd`";
    if [ "$0" != "${0%/*}" ]; then
        reldir="${0%/*}";
    fi;
    if [ "${reldir#/}" != "$reldir" ]; then
        absdir=`cd $reldir && pwd`;
    else
        absdir=`cd $thisdir/$reldir && pwd`;
    fi;
    echo $absdir
}

search-fileknow()
{ 
  . require.sh
  require url
  for Q; do
   (Q=${Q// /-}
	Q=$(url_encode_args "=$Q")
	SURL="http://fileknow.org/${Q#=}"
	URLS=$SURL
	PIPE="$(basename "${0#-}" .sh)-$$"
	trap 'rm -f "$PIPE"' EXIT INT QUIT
	rm -f "$PIPE"; mkfifo "$PIPE"
	
	while [ $(countv URLS) -gt 0 ]; do
	  (set -x; dlynx.sh "$(indexv URLS 0)")	 >"$PIPE" &
	  shiftv URLS
	  while read -r LINE; do
		case "$LINE" in
		  */download/*) pushv DLS "$LINE" ;;
		  *#[0-9]*) 		  
		    OFFS=${LINE##*\#}
		    OFFS=$(( (OFFS - 1) * 10 ))
		    pushv URLS "$SURL?n=$OFFS" ;;
		  *) continue ;;
		esac
        echo "$LINE"
	  done <"$PIPE"
	  wait 
	done) || return $?	  
  done 
}

set-builddir() {
  CCPATH=$(which ${CC:-gcc})
  case "$CCPATH" in
    */mingw??/*) CCHOST=${CCPATH%%/mingw??/*}; CCHOST=${CCHOST##*/} ;;
    *) CCHOST=$("$CCPATH" -dumpmachine);	CCHOST=${CCHOST%$r} ;;
	esac
	builddir=build/$CCHOST
	mkdir -p $builddir
	echo "$builddir"
}

set-devenv() {
  DEST=${1%/bin*}/bin
  PATH="$DEST:$(explode : "$PATH" |grep -v "$DEST"|implode :)"
}

set-ps1()
{
    local b="\\[\\e[37;1m\\]" d="\\[\\e[0;38m\\]" g="\\[\\e[1;36m\\]" n="\\[\\e[0m\\]";
    export PS1="$n\\u$g@$n\\h$g<$n\\w$g>$n \\\$ "
}

sf-get-cvs-modules() {
 (CVSCMD="cvs -z3 -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG co"
#  CVSPASS="cvs -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG login"
CVSPASS='echo "${GREP-grep} -q @$ARG.cvs.sourceforge.net ~/.cvspass 2>/dev/null || cat <<\\EOF >>~/.cvspass
\1 :pserver:anonymous@$ARG.cvs.sourceforge.net:2401/cvsroot/$ARG A
EOF"'
  for ARG; do
    CMD="curl -s http://$ARG.cvs.sourceforge.net/viewvc/$ARG/ | ${SED-sed} -n \"s|^\\([^<>/]\+\\)/</a>\$|\\1|p\""
   (set -- $(eval "$CMD")
    test $# -gt 1 && DSTDIR="${ARG}-cvs/\${MODULE}" || DSTDIR="${ARG}-cvs"
    CMD="${CVSCMD} -d ${DSTDIR} -P \${MODULE}"
    #[ -n "$DSTDIR" ] && CMD="(cd ${DSTDIR%/} && $CMD)"
    CMD="echo \"$CMD\""

    CMD="for MODULE; do $CMD; done"
    [ -n "$DSTDIR" ] && CMD="echo \"mkdir -p ${DSTDIR%/}\"; $CMD"
    [ -n "$CVSPASS" ] && CMD="$CVSPASS; $CMD"
    [ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
    eval "$CMD")
  done)
}

sf-get-git-repos() {
  require xml
 (for ARG; do
    curl -s  "http://sourceforge.net/p/$ARG/code-git/ci/master/tree/" |
      xml_get a data-url |
      head -n1
  done |
    ${SED-sed} "s|-git\$|| ;; s|-code\$||" |
    addsuffix "-git")
}

sf-get-svn-modules() {
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ |
      xml_get a data-url |
      head -n1
  done |
    ${SED-sed} "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}

shell-functions()
{
    ( . require.sh;
    require script;
    declare -f | script_fnlist )
}

shiftv()
{
  I=${2:-1}
  
    eval "while [ \$((I)) -gt 0 ]; do case \"\${$1}\" in
    *[\$IFS]*) $1=\"\${$1#*[${IFS}]}\" ;;
  *) $1=\"\" ;;
esac 
    : \$((I--))
  done"
}

shortcut-cmd() {
    readshortcut -a -f "$1" | ${SED-sed} 's,^Arguments:\s*\(.*\),-a\n"\1",
    s,^Description:\s\+\(.*\),-d\n"\1",g
    s,^Icon Library Offset:\s*\(.*\),-j\n\1,g
    s,^Icon Library:\s*\(.*\),-i\n\"\1\",g
    s,^Working Directory:\s*\(.*\),-w\n"\1",g
    s,^Show Command:\s*\(.*\),-s\n"\1",g
    s,^Target:\s*\(.*\),"\1",g
    1 i\
readshortcut
'
}

show-builtin-defines() {
 (NARG=$#
  CMD='"$ARG" -dM -E - <<EOF
EOF'
  if [ "$NARG" -gt 1 ]; then
    CMD="$CMD | addprefix \"\$ARG\":"
  fi
  eval "for ARG; do
    $CMD
  done")
}

sln-version() { 
 (while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -vs* | --vs*) E='$VSVER'; shift ;;
       -vc* | --vc*) E='$VCVER'; shift ;;
      -f | --file) E='$FVER'; shift ;;
      *) break ;;
    esac
  done
  : ${E='"$FVER"${VSVER:+ "$VSVER"}'}
  [ $# -gt 1 ] && E='"$ARG": '$E
  
  for ARG in "$@"; do
   (exec < "$ARG"
    read LINE
    while [ "${#LINE}" -lt 4 ]; do  read  LINE ; done # skip BOM    
    FVER=${LINE##*"Version "}
    read -r LINE
    case "$LINE" in
      *\ 20[01][0-9]\ *) LINE=${LINE%%" ${LINE##*20[01][0-9]}"*} ;;
    esac
    case "$LINE" in 
      *Version\ *) FVER=${LINE##*"Version "} ;;
      *"Visual Studio 20"[01][0-9]*) VSVER=${LINE##*Visual*"Studio "}; VSVER=${VSVER%%" "*} ;;
      *\ 20[01][0-9]) VSVER=${LINE##*" "} ;;
    esac
    case "$E" in
      *\$VCVER*) VCVER=$(vs2vc "$VSVER") ;;
    esac
    eval "echo $E")
  done)
}

sndfile-duration()
{ 
    for ARG in "$@";
    do
        I=$(sndfile-info "$ARG"| sed 's,^Duration[: ]*,,p' -n);
        echo "$ARG${SEP-|}$I";
    done
}

some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}

splitrev () {
   (IFS=${1-" "};
    S=${IFS%"${IFS#?}"};
    R=${2-"$S"}
    while read -r LINE; do
        set -- $LINE;
        OUT=;
        for F in "$@"; do
            OUT="$F${OUT:+$R$OUT}";
            shift
        done
        echo "$OUT"
    done)
}

split()
{
    local _a__ _s__="$1";
    for _a__ in $_s__;
    do
        shift;
        eval "$1='`echo "$_a__" | ${SED-sed} "s,','\\\\'',g"`'";
    done
}

srate()
{
  ( N=$#
  for ARG in "$@";
  do
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*\\([A-Za-z]*\\)Hz.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1\\2,p"

    SRATE=$(file "$ARG" |${SED-sed} -n "$EXPR" |${SED-sed} 's,[Kk]$,000,')
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$SRATE" && echo "$SRATE" || (
      #mminfo "$ARG" | ${SED-sed} -n "/Sampling rate[^=]*=/ { s,Hz,,; s,[Kk],000, ; s,\.[0-9]*\$,, ; s|^|$ARG:|; p }" | tail -n1
      SRATE=$(mminfo "$ARG" | ${SED-sed} -n "/Sampling rate[^=]*=/ { s,.*[:=],,; s,Hz,,; s,\.[0-9]*\$,, ; s|^|$ARG:|;  p }" | tail -n1)
      SRATE=${SRATE##*:}
      case "$SRATE" in
          *[Kk])
             CMD='SRATE=$(echo "'${SRATE%[Kk]}' * 1000" | bc -l); SRATE=${SRATE%.*}'
             #echo "$CMD" 1>&2
             eval "$CMD"
          ;;
       esac
      [ "$N" -gt 1 ]  && SRATE="$ARG:$SRATE"
      echo "$SRATE"


      )
  done )
}

submatch()
{
    local arg exp src dst result=$1 && shift;
    for arg in "$@";
    do
        exp="${arg#*=}";
        dst="${arg%$exp}";
        dst="${dst%=}";
        src="${exp%%[!A-Za-z_]*}";
        exp="${exp#$src}";
        eval ${dst:=$result}='${'${src:=$result}$exp'}';
    done
}

 subst-build-cmd() {
  : ${vs=2013} ${vc=12}

	s() {
	  ${SED-sed} 's,20[01][0-9],'$vs',g ;; s, [8-9] , '$vc' ,g  ;; s, 1[0124] , '$vc' ,g' "$@"
	}
	for x in ${@:-build/vs2008-*/build.cmd}; do
		y=$(s <<<"$x")
		mkdir -p "$(dirname "$y")"
		s < "$x" >"$y"
		echo "$y"
	done
}

subst-script()
{
    local var script value IFS="$obj_s";
    for var in "$@";
    do
        if [ "$var" != "${var%%=*}" ]; then
            value=${var#*=};
            value=`echo "$value" | ${SED-sed} 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@${var%%=*}@°`array_implode value '\n'`°g";
        else
            value=`var_get "$var"`;
            value=`echo "$value" | ${SED-sed} 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@$var@°`array_implode value '\n'`°g";
        fi;
    done;
    array_implode script ';'
}

suffix-num() {
 (for N; do
    case "$N" in
      [0-9]*P) N=$(multiply-num "${N%P} * 1099511627776") ;;
      [0-9]*G) N=$(multiply-num "${N%G} * 1073741824") ;;
      [0-9]*M) N=$(multiply-num "${N%M} * 1048576") ;;
      [0-9]*[Kk]) N=$(multiply-num "${N%[Kk]} * 1024") ;;
    esac
    echo ${N%.*}
  done)
}

svgsize() {
(while :; do
   case "$1" in
		-xy | --xy) XY=true; shift ;;
*) break ;;
esac
done

  sed -n  's,.*viewBox=[^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\)[^0-9][^0-9]*\([0-9][0-9]*\).*,\1 \2 \3 \4,p' "$@" | 
	(IFS=" "; while  read -r x y w h; do

	if [ "$XY" = true ]; then
			echo x$(expr "$w" - "$x")Y$(expr "$h" - "$y")
		else
			echo $(expr "$w" - "$x") $(expr "$h" - "$y")
	fi
	done)
	)
}

symlink-lib()
{
    ( while :; do
        case "$1" in
            -p)
                PRINT_ONLY=echo;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    for ARG in "$@";
    do
        ( IFS=".";
        set -- $ARG;
        unset NAME;
        while [ "$1" != so ]; do
            NAME="${NAME+$NAME${IFS:0:1}}$1";
            shift;
        done;
        I=$(( $# - 1 ));
        N=$#;
        unset PREV;
        while [ "$I" -ge 1 ]; do
            EXT=$(rangearg 1  "$I" "$@");
            LINK="$NAME${EXT:+.$EXT}";
            TARGET="$ARG";
            [ -n "$PREV" ] && TARGET="$PREV";
            ${PRINT_ONLY} ln -svf "$TARGET" "$LINK";
            I=$((I - 1));
            PREV="$LINK";
        done );
    done )
}

tcp-check() {
        (TIMEOUT=10
        for ARG; do
        HOST=${ARG%:*}
        PORT=${ARG#$HOST:}

        if type tcping 2>/dev/null >/dev/null; then
          CMD='tcping -q -t "$TIMEOUT" "$HOST" "$PORT"; echo "$?"'
        else
          CMD='echo -n |(nc -w 10 "$HOST" "$PORT" 2>/dev/null >/dev/null;  echo "$?")'
        fi

        RET=`eval "$CMD"`

        if [ "$RET" -eq 0 ]; then
          echo "$HOST:$PORT"
        fi

        if [ $# -le 1 ]; then
          exit "$RET"
        fi
      done)
}

terminfo-file()
{
    ( for ARG in "$@";
    do
        F="/usr/share/terminfo/`firstletter "$ARG"`/$ARG";
        test -e "$F" && echo "$F" || {
            echo "$F not found" 1>&2;
            exit 1
        };
    done )
}

tgz2txz()
{
    ( for ARG in "$@";
    do
        zcat "$ARG" | ( xz -9 -v -f -c > "${ARG%.tgz}.txz" && rm -vf "$ARG" );
    done )
}

title()
{
        (
id3get "$1" 'TIT[0-9]'
        )

}

to-expr() { echo "${*//[!-a-zA-Z0-9_=%:\/ <>\']/.}"; }

to-sed-expr()
{
 ([ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} 's|[.*\\]|\\&|g ;; s|\[|\\[|g ;; s|\]|\\]|g')
}

to-sed-expr()
{
 ([ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} 's|[.*\\]|\\&|g ;; s|\[|\\[|g ;; s|\]|\\]|g')
}

triplet-to-arch()
{ 
    ( for TRIPLET;  do
        OS=; BITS=; TRIPLET=${TRIPLET##*/}
       (case "$TRIPLET" in 
            *x86?64* | *x64* | *amd64*)
                BITS=64
            ;;
            *i[3-8]86* | *x32* | *x86*)
                BITS=32
            ;;
        esac;
        OS=${TRIPLET%-gnu};
        OS=${OS##*-};
        OS=${OS%32};
        echo "${OS##*-}$BITS" );
    done )
}

umount-all()
{
    for ARG in "$@";
    do
        umount "$ARG";
    done
}

umount-matching()
{
    ( grep-e "$@" < /proc/mounts | {
        IFS=" ";
        while read -r DEV MNT TYPE OPTS N M; do
            echo "Unmounting $DEV, mounted at $MNT ..." 1>&2;
            umount $ADDOPTS "$MNT" || umount $ADDOPTS "$MNT";
        done
    } )
}

undotslash()
{
    ${SED-sed} -e "s:^\.\/::" "$@"
}

unescape-newlines() {
  ${SED-sed} -e '\|\\$| {
  :lp
  N
  \|\\$| b lp
  s,\\\n\s*,,g
  }' "$@"
}

unix2date()
{
    date --date "@$1" "+%Y/%m/%d %H:%M:%S"
}

unmount-all()
{
    for ARG in "$@";
    do
        umount "$ARG";
    done
}

<<<<<<< HEAD
=======
<<<<<<< HEAD
unpack()
{
    case $(mime "$1") in
        application/x-tar)
            tar ${2+-C "$2"} -xf "$1" && return 0
        ;;
        application/x-zip)
            unzip -L -qq -o ${2+-d "$2"} "$1" && return 0
        ;;
    esac;
    return 1
}

>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
unpackable()
{
    case $(mime $1) in
        'application/x-tar')
            return 0
        ;;
        'application/x-zip')
            return 0
        ;;
    esac;
    return 1
}

<<<<<<< HEAD
=======
=======
>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
unpack-deb()
{
    ( for ARG in "$@";
    do
        ( TEMP=` mktemp -d `;
        trap 'rm -rf "$TEMP"' EXIT;
        ARG=` realpath "$ARG"`;
        DIR=${DESTDIR-"$PWD"};
        DEST="$DIR"/$(basename "$ARG" .deb);
        cd "$TEMP";
        ar x "$ARG";
        mkdir -p "$DEST";
        tar -C "$DEST" -xf data.tar.gz;
        [ "$?" = 0 ] && echo "Unpacked to $DEST" 1>&2 );
    done )
}

<<<<<<< HEAD
=======
unpack()
{
    case $(mime "$1") in
        application/x-tar)
            tar ${2+-C "$2"} -xf "$1" && return 0
        ;;
        application/x-zip)
            unzip -L -qq -o ${2+-d "$2"} "$1" && return 0
        ;;
    esac;
    return 1
}

<<<<<<< HEAD
=======
unpackable()
{
    case $(mime $1) in
        'application/x-tar')
            return 0
        ;;
        'application/x-zip')
            return 0
        ;;
    esac;
    return 1
}

>>>>>>> e4bd1a765da15d7166eb1a92f6bc50f18279eb83
>>>>>>> 3169b748a89e855708cde4ae0d3044b124ea6a1f
usleep()
{
    local sec=$((${1:-0} / 1000000)) usec=$((${1:-0} % 1000000));
    while [ "${#usec}" -lt 6 ]; do
        usec="0$usec";
    done;
    sleep $((sec)).$usec
}

uuid-hexnums()
{
    getuuid "$1" | ${SED-sed} "s,[0-9A-Fa-f][0-9A-Fa-f], ${2:-0x}&,g" | ${SED-sed} "s,^\s*,, ; s,\s\+,\n,g"
}

var-get() {
 (while [ $# -gt 0 ]; do
    eval "echo \"\$$1\""
    shift
  done)
}

vc2vs() {
 (while :; do
    case "$1" in
      -c | --continue) CONT=true; shift ;;
      -t | --trail*) TRAIL=true; shift ;;
      *) break ;;
    esac
  done
  for ARG; do
   ARG=${ARG#*msvc}
   ARG=${ARG#-}
   ARG=${ARG##*"Visual Studio "}
   ARG=${ARG%%[/\\]*}
   ARG=${ARG#vc}
   NUM=${ARG%%[!0-9.]*}
   [ "$TRAIL" = true ] && T=${ARG#$NUM} || T=
   case "${NUM}" in
     8 | 8.0 | 8.00) echo 2005$T ;;
     9 | 9.0 | 9.00) echo 2008$T ;;
     10 | 10.0 | 10.00) echo 2010$T ;;
     11 | 11.0 | 11.00) echo 2012$T ;;
     12 | 12.0 | 12.00) echo 2013$T ;;
     14 | 14.0 | 14.00) echo 2015$T ;;
     *) [ "$CONT" = true ] && echo "$ARG" || { echo "No such Visual Studio version: $ARG" 1>&2; exit 1; } ;;
   esac
  done)
}

vcget() {
echo "vcget \"$1\" $2" 1>&2
  case "$1" in
	*2005* | *2008* | *2010* | *2012* | *2013* | *2015*)
	  VC=$(vs2vc -0 "$1")
	  VS=$(vc2vs "$VC")
      ARCH=${1##*$VS}
      
	;;
	  *)
	  VS=$(vc2vs "$1")
	  VC=$(vs2vc -0 "$VS")
      ARCH=${1##*${VC%.*}-}
	;;
  esac
  : ${ARCH:=x86}
  ARCH=${ARCH#[!0-9A-Za-z_]}
  CMAKE_ARCH=
  case "$ARCH" in
   amd64|x64) ARCH="amd64" CMAKE_ARCH="Win64" ;;
  esac
  
  case "$ARCH" in
    amd64|amd64_arm|amd64_x86|arm|ia64|x86_amd64|x86_arm|x86_ia64) ARCHDIR="$ARCH" ;;
    *) ARCHDIR= ;;
  esac
  
echo "CMAKE_ARCH=$CMAKE_ARCH" 1>&2

  shift

  VSINSTALLDIR="${PROGRAMFILES% (x86)}${ProgramW6432:+ (x86)}\\Microsoft Visual Studio $VC"
  VCINSTALLDIR="$VSINSTALLDIR\\VC"
  BINDIR="$VCINSTALLDIR\\bin${ARCHDIR:+\\$ARCHDIR}"
  CL="$BINDIR\\cl.exe"
  DevEnvDir="$VCINSTALLDIR\\Common7\\IDE"
  DEVENV="$DevEnvDir\\devenv.exe"
  BITS=${ARCHDIR##*[!0-9]}

#echo "ARCH=$ARCH" 1>&2

  VCVARSALL="$VCINSTALLDIR\\vcvarsall.bat"

  case "$VC" in
    9.0) VCVARSARCH="$BINDIR\\vcvars${ARCHDIR:-32}.bat" ;;
    *) VCVARSARCH="$BINDIR\\vcvars${BITS:-32}.bat" ;;
  esac

  VCVARSCMD="\"$VCVARSALL\" ${ARCH:-x86}"

  VCNAME="Microsoft Visual Studio $VC${ARCHDIR:+ ($ARCHDIR)}"
  CMAKEGEN="Visual Studio ${VC%.0*} ${VS}" #${CMAKE_ARCH:+ $CMAKE_ARCH}"

   VSVARS="${ARCHDIR:+$VCVARSARCH}"
   : ${VSVARS:="$VSINSTALLDIR\\Common7\\Tools\\vsvars32.bat"}

  WindowsSdkDir=$(cmd /c 'reg query "HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows" /v "CurrentInstallFolder"' | ${SED-sed} -n "s|.*REG_SZ\s\+||p")

  local $(${GREP-grep
-a} -i -E "^\s*@?set \"?(INCLUDE|LIB|LIBPATH|FrameworkDir|FrameworkVersion|Framework35Version)=" "$VSVARS" | ${SED-sed} \
   -e "s,.*set \"\?\([^\"]\+\)\"\?,\1,i" \
   -e "s|%VCINSTALLDIR%|${VCINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%VSINSTALLDIR%|${VSINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%WindowsSdkDir%|${WindowsSdkDir//"\\"/"\\\\"}|g")

  case "$ARCHDIR" in
    *amd64*) CMAKEGEN="$CMAKEGEN Win64" ;;
  esac

  [ $# -eq 0 ] && set -- VCINSTALLDIR

  for VAR; do
    eval "O=\$$VAR"
#    echo "O=\"$O\"" 1>&2
    case "$O" in
      *\;*) echo "$O" ;;
      ?:\\*) ${PATHTOOL:-echo} "$O" ;;
      *) echo "$O" ;;
    esac
  done
}

vcodec()
{
    ( IFS="
";
      CMD='echo "${ARG:+$ARG:}$D"'
    while :; do
       case "$1" in
       *) break ;;
     esac
   done
    N="$#";
    for ARG in "$@"
    do
     ( D=$(mminfo "$ARG" |${SED-sed} -n 's,Codec ID=,,p ;  s,Writing library=,,p' )
       set -- $D
       [ $# -gt 1 ] && shift
#        while [ $# -gt 1 ]; do shift; done
        D="$1${2:+ $2}"
        [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD") || exit $?
    done )
}

verbosecmd() {
  CMD='"$@"'
  while :; do
    case "$1" in
      -2=1 | -err=out | -stderr=stdout) CMD="$CMD 2>&1"; shift ;;
      -1=* | -out=* | -stdout=*) CMD="$CMD 1>${1#*=}"; shift ;;
      -1+=* | -out+=* | -stdout+=*) CMD="$CMD 1>>${1#*=}"; shift ;;
      *) break ;;
    esac
  done
  echo "+ $@" 1>&2
  eval "$CMD; return \$?"
}

verbose() {
   (M="$*" A=`eval "echo \"\${$#}\""` IFS="
";
    if [ "$#" = 1 ]; then
        A=1;
    fi;
    if ! [ "$A" -ge 0 ]; then
        A=0;
    fi 2> /dev/null > /dev/null;
    if [ $(( ${VERBOSE:-0} )) -ge "$A" ]; then
        M "${M%?$A}";
    fi)
}

video-height()
{
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | ${SED-sed} -n "s|^Height=|$PFX|p";
    done )
}

video-width()
{
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | ${SED-sed} -n "s|^Width=|$PFX|p";
    done )
}

vlc-current-file()
{ 
    handle $(pid-args vlc.exe) | cut-ls-l 3 | filter-test -s | grep-videos.sh | sed 's,\\,/,g; 1p' -n
}

vlcfile()
{
    ( IFS="
";
    set -- ` handle -p $(vlcpid)|${GREP-grep} -vi "$(${PATHTOOL:-echo} "$WINDIR"| ${SED-sed} 's,/,.,g')"  |${SED-sed} -n -u 's,.*: File  (RW-)\s\+,,p'
`;
    for X in "$@";
    do
        X=`cygpath "$X"`;
        test -f "$X" && echo "$X";
    done )
}

vlcpid()
{
    ( ps -aW | ${GREP-grep} -i vlc.exe | awkp )
}

volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
			NAME=$("${COMSPEC//"\\"/"/"}" /c "vol ${drive%%/*}" | sed -n ' s,\x84,, ;  s,\r$,, ; s,.*\sist\?\s,,p')
      eval "$ECHO"
  done)
}

vs2vc() {
 (NUL=0
  while :; do
    case "$1" in
      -0 | -nul | --nul) : $((NUL++)); shift ;;
      -c | --continue) CONT=true; shift ;;
      -t | --trail*) TRAIL=true; shift ;;
      *) break ;;
    esac
  done
  N=
  while [ $((NUL)) -gt 0 ]; do
    N="${N}0"
    : $((NUL--))
  done
     [ "$TRAIL" = true ] && T=${ARG#*20[0-9][0-9]} || T=

  for ARG; do
   case "$ARG" in
     *2005*) echo 8${N:+.$N}$T ;;
     *2008*) echo 9${N:+.$N}$T ;;
     *2010*) echo 10${N:+.$N}$T ;;
     *2012*) echo 11${N:+.$N}$T ;;
     *2013*) echo 12${N:+.$N}$T ;;
     *2015*) echo 14${N:+.$N}$T ;;
     *) [ "$CONT" = true ] && echo "$ARG" || { echo "No such Visual Studio version: $ARG" 1>&2; exit 1; } ;;
   esac
  done)
}

w2c()
{
    ch-conv UTF-16 UTF-8 "$@"
}

waitproc()
{
    function getprocs()
    {
        for ARG in "$@";
        do
            pgrep -f "$ARG";
        done
    };
    while [ -n "$(getprocs "$@")" ]; do
        sleep 0.5;
    done
}

warn()
{
    msg "WARNING: $@"
}

win-get-environment()
{ 
 ( unset S VAR KEY GLOBAL 
  while :; do
    case "$1" in
      -m | --mixed) MIXED=true; shift ;;
      -s=* | --separator=*) S=${1#*=}; shift ;;
      -s*) S=${1#-s}; shift ;;
      -s | --separator) S=$2; shift 2 ;;
      -g | --global | --local*machine*) GLOBAL=true; shift ;;
      *) break ;;
    esac
  done
EXPR="s,.*REG_SZ\s\+\(.*\),\1, ; ${S+s|;|${S:-\\n}|g}"
[ "$MIXED" = true ] && EXPR="$EXPR; s|\\\\|/|g"
EXPR="/REG_SZ/ { $EXPR; p }"

#echo "EXPR=$EXPR" 1>&2
  [ "$GLOBAL" = true ] &&   KEY='HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' || KEY='HKCU\Environment'
  [ $# -le 0 ] && set -- PATH
  
  for VAR ; do 
    reg query "$KEY" /v "$VAR"
  done | sed -n "$EXPR"
    )
}

win-set-environment()
{ 
 ( unset VAR KEY GLOBAL  PRINT CMD
 CMD='reg add "$KEY" /v "$VAR" /t REG_SZ /d "$DATA" /f'
  while :; do
    case "$1" in
      -p | --print) CMD="echo \"${CMD//\"/\\\"}\""; shift ;;
      -g | --global | --local*machine*) GLOBAL=true; shift ;;
      *) break ;;
    esac
  done
  [ "$GLOBAL" = true ] &&   KEY='HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' || KEY='HKCU\Environment'
  
  for VAR ; do 
  (case "$VAR" in
     *=*) DATA=${VAR#*=}; VAR=${VAR%%=*} ;;
     *) eval "DATA=\${$VAR}" ;;
   esac
  
    eval "$CMD") || exit $?
  done 
    )
}

writefile() {
 (while :; do
   case "$1" in
     -a | --append) APPEND=true; shift ;;
     *) break ;;
   esac
  done
  FILE="$1"
  shift
  CMD='for LINE; do echo "$LINE"; done'
  [ "$APPEND" = true ] && CMD="$CMD >>\"\$FILE\"" || CMD="$CMD >\"\$FILE\""
  eval "$CMD")
}

x-fn()
{
 (MATCH=p
  NOMATCH=D
  while :; do
    case "$1" in
      -1 | --oneline) XTRA="$XTRA; s,\s\+, ,g" ;;
      -d | --delete) MATCH=d; NOMATCH='P;D;' ;;
      *) break ;;
    esac
    shift
  done

  FN="$1";
  shift;
  #: ${XTRA="$XTRA; s/^/-->/; s/\n/\n-->/g"}
  ${SED-sed} " :lp0
   \$ { /\n/! $NOMATCH; }
    N
    /\n/! b lp0

    /$FN[^\n]*\$/ {

      /)/ b endargs
      :lp1
      N
      /)/! b lp1

      :endargs

      /).*;\s*$/ b endfn

      :lp2
      N
      /\n}[ \t]*$/! b lp2
      :endfn
      $XTRA
      $MATCH

      :endlp
      d
      n
      b endlp
      q
    }
    $NOMATCH
    b lp0

  " "$@" | sed "/^}\$/q")
}

yaourt-cutnum() {
 #(NAME='\([^ \t/]\+\)';  ${SED-sed} "s|^${NAME}/${NAME}\s\+\(.*\)\s\+\(([0-9]\+)\)\(.*\)|\1/\2 \3 \5|")
 ${SED-sed} "s|\s\+\(([0-9]\+)\)\(.*\)| \2|"
}

yaourt-cutver() {
 (NAME='\([^ \t/]\+\)'
 ${SED-sed} "s|^${NAME}/${NAME}\s\+\([^ \t]\+\)\s\+\(.*\)|\1/\2 \4|")
}

yaourt-joinlines() {
(while :; do
   case "$1" in 
		 -R | --remove-repo*) REMOVE_REPO="s|^[^/ ]\\+/||"; shift ;;
		 -V | --remove-ver*) REMOVE_VER="s|^\([^/ ]\\+\)/\([^/ ]\\+\) \([^ ]\\+\) |\\1/\\2 |"; shift ;;
		 -I | --no*inst*) NO_INSTALLED="/\\[installed/!"; shift ;;
		 -r | --remove-rat*) REMOVE_RATING="s|)\s\+\(([^)]\+)\)|) |"; shift ;;
		 -n | --remove-num*) REMOVE_NUM="s|^\([^/ ]\\+\)/\([^/ ]\\+\) \([^ ]\\+\) \(([^)]\+)\)|\\1/\\2 \\3|"; shift ;;
		 -s | --*sep*) COLSEP="$2";  shift 2 ;;
		 *) break ;;
		esac
	done

  EXPR="\\|^[^/ ]\\+/[^/ ]\\+\\s| { :lp; ${REMOVE_RATING}; ${REMOVE_NUM}; ${REMOVE_VER}; ${REMOVE_REPO}; N; /\\n\\s[^\\n]*$/ { s,\\n\\s\\+,${COLSEP- - },; b lp }; s,\\n\\s\\+, - ,g; :lp2; /\\n/ { s,[^[:print:]\\n],,g; ${NO_INSTALLED} P; D; b  lp2; }; b lp }"
  exec sed -e "$EXPR" "$@")
} 
pacman-joinlines() { yaourt-joinlines "$@"; }

yaourt-pkgnames() {
 (NAME='\([^ \t/]\+\)'
 ${SED-sed} -n "s|^${NAME}/${NAME}\s\+\(.*\)|\2|p")
}

yaourt-search() { 
(: ${NPAD=32} ${VPAD=24} ${COLS=$(tput cols)}; while :; do
   case "$1" in
		 -D | --no*desc*) EVARS='$N $V'; shift ;;
		 -N | --name-only) EVARS='$N'; shift ;;
		-*) pushv OPTS "$1"; shift ;;
		*) break ;;
		esac
	done
set -- ${@//"^"/"/"}
#set -- ${@//[.*]/" "}
#set -- ${@//\*/\.\*}
#[!\.\*[:alnum:]]/}
set -- ${@//[!.*[:alnum:]]/}
 CMD="yaourt-search-cmd"
 [ $# -gt 0 ] && CMD="$CMD \"\${@//[!.*[:alnum:]]/}\"" 
 CMD="$CMD | yaourt-search-output"
 if is-a-tty; then
     [ $# -gt 0 ] && CMD="$CMD | ${GREP-grep -a} -E \"($(IFS="|"; echo "$*"))\""
	else
		 NPAD= VPAD=
 fi
 eval "$CMD")
}

yaourt-search-cmd() {
  [ $# -gt 0 ] || set -- ""
  for Q in "$@"; do
      (IFS="| $IFS"; Q=${Q//"\\\\"/"\\"}; Q=${Q//"\\."/"."}; Q=${@//"\\*"/"*"}; set -- $Q
	 ([ "$DEBUG" = true ] && set -x
${YAOURT:-${YAOURT:-command yaourt}} -Ss $@) | yaourt-joinlines -s "|" $OPTS | 
   command ${GREP-grep -a}  -i -E "($*)")
 done
}

yaourt-search-output() {
  : ${EVARS='$N $V $DESC'}
	IFS=" "
	while read -r NAME VERSION_DESC; do
    DESC=${VERSION_DESC##*"|"}
    VERSION=${VERSION_DESC%%"|"*}
    NUM="(${VERSION#*"("}"
    VERSION=${VERSION%"$NUM"}
    VERSION=${VERSION%" "}

   (N=$(printf "%${NPAD+-$NPAD}s" "${NAME}"  )
    [ $((NPAD)) -gt 0 -a ${#N} -gt $((NPAD)) ] && VPAD=$((VPAD - (  ${#N}  -    $((NPAD)) ) ))
    
    V=$(printf "%${VPAD+-$VPAD}s"  "${VERSION}" )
    #MAXDESC=$(( COLS - (NPAD + 1 + VPAD + 1) )) 
    MAXDESC=$(( COLS - ${#N} - 1 - ${#V} - 1 ))
    if [ ${#DESC} -gt $(( COLS - ${#N} - 1 - ${#V} - 1))  ]; then
			DESC=${DESC:1:$((MAXDESC-3))}...
    fi
    eval "echo \"$EVARS\"")
	done
}
pacman-search() { YAOURT="pacman" yaourt-search "$@"; }
yay-search() { YAOURT="yay" yaourt-search "$@"; }
pacaur-search() { YAOURT="pacaur" yaourt-search "$@"; }
pakku-search() { YAOURT="pakku" yaourt-search "$@"; }
aurutils-search() { YAOURT="aurutils" yaourt-search "$@"; }

yes()
{
    while :; do
        echo "${1-y}";
    done
}

#
# https://gist.github.com/nk23x/011fff7fa8db4840aed9#file-youtube-dl_bs_whole_season
#
youtube-dl_bs_whole_season() {
  youtube-dl-launcher.sh $(for f in \
  $(wget -q -O - "$@" | grep -i streamcloud-1 | perl -pe 's/.*href=\"/http:\/\/bs.to\//g;s/-1\"(.*)/-1/g;'); do \
    wget -q -O - ${f} | grep -i 'link zum orig' | perl -pe 's/.*http(.*).html.*/http$1.html/g;';\
    done) 
}

yum-joinlines()
{ 
    ${SED-sed} '/^[^ ]/ { :lp; N; /\n\s.*:\s/ { s,\n\s\+:\s*, , ; b lp };  :lp2; /\n/ { P; D; b  lp2; } }' "$@"
}

yum-rpm-list-all-pkgs()
{
  require rpm

  yum list all >yum.list
  #${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  ${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1\2,p' <yum.list >pkgs.list
  #rpm_list |sort |${SED-sed} 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  rpm_list |sort |${SED-sed}  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

  rpm_expr=^$(grep-e-expr $(<rpm.list))

  ${GREP-grep} -v -E "$rpm_expr\$" <pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}
