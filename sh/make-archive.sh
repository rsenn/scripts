#!/bin/bash
IFS="
"
SPC=" "
BS="\\"
: ${LEVEL:=3}
: ${EXCLUDE="*.git*
*~
*.stackdump
build/*
*.orig
*.rej
*.tmp
.[oa]
.obj
config.status
CMakeCache.txt"}


make_archive() {
  ARGS="$*"
        : ${max_length=120}
  case "$EXCLUDE" in
    *"
"*) ;; 
    *\ *) IFS="$IFS "; set -f ; set -- $EXCLUDE;  EXCLUDE="$*"; set +f; IFS="
" ;;
  esac
  set -- $ARGS
  while :; do
    case "$1" in
      -[0-9]) LEVEL=${1#-}; shift ;;
      -t) TYPE=$2; shift 2 ;;
      -x | --debug) DEBUG=true; shift ;;
                    -v | --verbose) VERBOSE=$(( ${VERBOSE:-0} + 1 )); shift ;;
      -q | --quiet) QUIET=true; shift ;;
      -r | --remove*) REMOVE=true; shift ;;
      -d=* | --dest*DIR*=*) DESTDIR=${1#*=}; shift ;; 
      -d | --dest*DIR*) DESTDIR=$2; shift 2 ;;
      -D | --no*date*) NODATE=true; shift  ;;
      -n=* | --name=*) NAME=${1#*=}; shift ;;
      -n | --name) NAME=$2; shift  2 ;;
      -[EX] | --exclude) pushv EXCLUDE "$2"; shift 2 ;; 
      -[EXx]*) pushv EXCLUDE "${1#-?}"; shift ;; 
      -[EXx]=*) pushv EXCLUDE "${1#*=}"; shift ;;
      -e=* | --exclude=*) pushv EXCLUDE "${1#*=}"; shift ;;
      *) break ;;
    esac
  done
   case "$TYPE" in
          #*xz*) LEVEL=$((LEVEL * 6 / 9)) ;;
            *) ;;
        esac
  type gtar 2>/dev/null >/dev/null && TAR=gtar ||
  { type gtar 2>/dev/null >/dev/null && TAR=gtar; }
  : ${TAR=tar}
  [ "$DESTDIR" ] &&
  ABSDESTDIR=`cd "$DESTDIR" && pwd`
  while [ -d "$1" ]; do
    DIRS="${DIRS:+$DIRS
}$1"; shift
  done
  debug "+ DIRS="$DIRS
  while [ $# -gt 0 ]; do
    if [ "$1" ]; then
      case "$1" in
        *.tar*|*.7z|*.rar|*.zip|*.t?z|*.cpio)   ARCHIVE=$1; shift ;;
      esac
    fi
  done
  DIR1=$(set -- ${DIR//$SPC/$BS$SPC}s; echo "${1##*/}")

  if [ -z "$ARCHIVE" -a $(count $DIRS) -ge 1 ]; then
     FORCMD='for DIR in $DIRS; do (exec_cmd cd "$DIR"; mkarchive); done'
  elif [ -n "$ARCHIVE" ]; then
    FORCMD='mkarchive'
  fi
 eval "$FORCMD" 
}

mkarchive() {
  WD=${PWD}
  if [ -n "$DIR1" -a "${DIR1#$WD}" != "${DIR1}" ]; then
    DNAME=${DIR1#$WD}
    DNAME=${DNAME#[\\/]}
  else
    DNAME="${WD}"
  fi
  #echo "DNAME=$DNAME" 1>&2 
  DIR=${2:-.}
  if [ -z "$ARCHIVE" ]; then
    if [ -z "$NAME" ]; then
      if [ "$DESTDIR" ]; then
        NAME=${DNAME#$ABSDESTDIR}
        NAME=${NAME#/}
        NAME=${NAME//[\\/]/-}
      else
        NAME=${DNAME##*/}
      fi
      NAME=${NAME#.}
      NAME=${NAME%/}
    fi
    #echo "NAME=$NAME" 1>&2 
    ARCHIVE=${DESTDIR:-..}/${NAME##*/}
    [ "$NODATE" != true ] && ARCHIVE=$ARCHIVE-$(isodate.sh -r ${DIR:-.})   #`date ${DIR:+-r "$DIR"} +%Y%m%d`
    ARCHIVE=$ARCHIVE.${TYPE:-7z}
        elif [ -n "$ARCHIVE" -a -f "$ARCHIVE" ]; then
            if [ "$FORCE" != true ]; then
            verbose "Archive '$ARCHIVE' already exists!" 0
            exit 1
        fi
  fi
  set -f
  case "$ARCHIVE" in
    *.iso) CMD="${genisoimage:-mkisofs} -f -L -R -J -o \"\$ARCHIVE\"  $(create_list "-exclude " $EXCLUDE) \$DIR" ;;
    *.7z) CMD="${sevenzip:-7za} A -mx=$(( $LEVEL * 5 / 9 )) \"\$ARCHIVE\" $(create_list "-x!" $EXCLUDE) \$DIR" ;;
                *.zip) CMD="zip -${LEVEL} $(test "$REMOVE" = true && echo -m) -r \"\$ARCHIVE\" \$DIR $(create_list "-x " $EXCLUDE) " ;;
                *.rar) CMD="rar A -m$(($LEVEL * 5 / 9)) $(test "$REMOVE" = true && echo -df) -r $(create_list "-x" $EXCLUDE) \"\$ARCHIVE\" \$DIR" ;;
    *.tar) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) -f \"\$ARCHIVE\"" ;;
    *.txz|*.tar.xz) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | xz -$LEVEL >\"\$ARCHIVE\"" ;;
    *.tlzma|*.tar.lzma) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | lzma -$LEVEL >\"\$ARCHIVE\"" ;;
    *.tlzip|*.tar.lzip) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | lzip -$LEVEL >\"\$ARCHIVE\"" ;;
    *.tlzo|*.tar.lzo) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | lzop -$LEVEL >\"\$ARCHIVE\"" ;;
    *.tgz|*.tar.gz) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | gzip -$LEVEL >\"\$ARCHIVE\"" ;;
    *.tbz2|*.tbz|*.tar.bz2) CMD="$TAR -c $(test "$QUIET" != true && echo -v) $(test "$REMOVE" = true && echo --remove-files) $(create_list --exclude= $EXCLUDE) \$(dir_contents ${DIR//$SPC/$BS$SPC}) | bzip2 -$LEVEL >\"\$ARCHIVE\"" ;;
  esac
  CMD='rm -vf -- "$ARCHIVE"; '$CMD
  [ "$QUIET" = true ] && CMD="($CMD) 2>/dev/null" || CMD="($CMD) 2>&1"
    [ "$REMOVE" = true ] && CMD="$CMD && rm -rf \"\$DIR\""
        verbose "CMD='$(max_length $max_length "$CMD")'" 2

        IFS="$IFS "
  cmdexec $CMD  && {
    verbose "Created ARCHIVE '$ARCHIVE'" 1
  }
}

max_length() { 
 (MAX=$1;
  shift;
  A=$*;
  L=${#A};
  [ $((L)) -gt $((MAX)) ] && A="${A:1:$((MAX - 3))}...";
  echo "$A")
}
cmdexec()  { 
   (IFS=" ""
    " R= C= E='eval "$C"' EE=': ${R:=$?}; [ "$R" = "0" ] && unset R'
    [ "$DEBUG" = true ] && E='eval "echo \"XX: \$C\"" 1>&2;'$E
    o() {  X_RM_O="${X_RM_O:+$X_RM_O$IFS}$1"; E="exec >>'$1'; $E"; }
    while [ $# -gt 0 ]; do case "$1" in 
                -o) o "$2"; shift 2 ;; -o*) o "${1#-o}"; shift ;;
            -w) E="(cd '$2' && $E)"; shift 2 ;;     -w*) E="(cd '${1#-w}' && $E)"; shift ;;
            -m) E="$E 2>&1"; shift ;;
        *) break ;;
        esac;  done;  C="$*"; #EC=`max_length $max_length "$C"`; [ "$DEBUG" = true ] && eval max_length $max_length "EVAL: $E" 1>&2 
#    (trap "$EE;  [ \"\$R\" != 0 ] && echo \"\${R:+\$IFS!! (exitcode: \$R)}\" 1>&2 || echo 1>&2; exit \${R:-0}" EXIT
    eval "echo -n \"@@ $C\" 1>&2";  eval "($E); $EE";  exit ${R:-0}) ; return $?
}
debug()
{
    [ "$DEBUG" = true ] && echo "DEBUG: $@" 1>&2
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
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
bce() {
 (IFS=" "; echo "$*" | (bc -L || echo "ERROR: Expression '$*'" 1>&2)) | ${SED-sed} -u '/\./ s,\.\?0*$,,'
}

bci() {
 (IFS=" "; : debug "EXPR: bci '$*'" ; bce "($*) + 0.5") | ${SED-sed} -u 's,\.[0-9]\+$,,'
}

create_list() {
 ( 
 #: ${separator=" "}
 : ${separator="','"}
  #OUTPUT=
  OUTPUT="$1{'"
  shift
  LIST=
  [ $# -gt 0 ] && {
  for arg; do 
    LIST="${LIST:+$LIST$separator}$arg"
  done
  OUTPUT="$OUTPUT$LIST'}"
  echo "$OUTPUT"
  } )
}

match() {
  (while :; do
    case "$1" in
      -v | --invert*) INVERT=true; shift ;;
      *) break ;;
    esac
  done
  EXPR="$1"; shift
  [ "$INVERT" = true ] && EXPR=$EXPR' ) ;;
*' 
  CMD='case $LINE in
  '$EXPR') echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

implode() { 
    ( unset D S C I;
    S="$1";
    shift;
    C='D="${D+$D$S}$I"';
    if [ $# -gt 0 ]; then
        C="for I; do $C; done";
    else
        C="while read -r I; do $C; done";
    fi;
    eval "$C";
    echo "$D" )
}

dir_contents() {
( 
#: ${SEP='" "'}
: ${SEP=' '}
verbose  "dir_contents \"$(implode "$SEP" "$@")\"" 3
  case "$1" in 
    . | "." | \".\" | .*) 
      EXCLUDE="$(implode "|" $EXCLUDE)" 
      set -- $(ls -a -1 |grep -v -E '^(\.|\.\.)$' |sort -u |match -v "${EXCLUDE:-''}")
      ;;
    *)
      ;;
  esac 
       implode "$SEP" "$@"
  #IFS=" "; echo "$*"
  )
}
count() {
    echo $#
}
exec_cmd() {
    debug "$@";
    "$@"
}

make_archive "$@"
