#!/bin/bash

IFS="
"
################################################################################
filter_test() {
 (IFS="
" EXCLAM='! '
  unset ARGS NEG
  while :; do
    case "$1" in
      -X | --debug) DEBUG=true; shift ;;
      -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s | -u | -w | -x) ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}$1 \"\$LINE\""; shift; unset NEG ;;
      -E) ARGS="${ARGS:+$ARGS }${NEG+$EXCLAM}-f \"\$LINE\" -a ${NEG-$EXCLAM}-s \"\$LINE\""; shift; unset NEG ;;
      -a | -o) ARGS="${ARGS:+$ARGS }$1"; shift; unset NEG ;;
      '!') [ "${NEG-false}" = false ] && NEG="" || unset NEG; shift ;;
      *) break ;;
    esac
  done
  CMD='while read -r LINE; do
  [ '$ARGS' ] && echo "$LINE"
done';
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}

################################################################################
retok() {
  eval 'shift 2; IFS="'$1'"; set -- $*; IFS="'$2'"; echo "$*"'
}

################################################################################
isin () {
 (needle="$1"
  while [ "$#" -gt 1 ]; do
    shift
    test "$needle" = "$1" && exit 0
  done
  exit 1)
}

################################################################################
pushv_unique() {
  v=$1
  #IFS=${IFS%${IFS#?}}
  shift
  for s; do
    if eval '! isin $s ${'$v'}'; then
      pushv "$v" "$s"
    else
      return 1
    fi
  done
}

################################################################################
pushv() {
  eval "shift; $1=\"\${$1:+\$$1
}\$*\""
}

################################################################################
setv() {
  while [ $# -gt 0 ]; do
    case "$1" in
      *=*) eval "${1%%=*}=\"\${1#*=}\"" ;;
      *) eval "$1=\"\$2\""; shift  ;;
    esac
    shift
  done
}

################################################################################
getv() {
  P="$1"; shift
  while [ $# -gt 0 ]; do
    eval "$1=\"\${${P}_$1}\""
    shift
  done
}

################################################################################
get_configure_scripts() {
  SCRIPT=${1:-"configure"}
  [ -e "$SCRIPT" ] && pushv CONFIGURE_SCRIPTS "$SCRIPT"

  CONFIGDIRS=$( grep 'configdirs[a-z_]*="' "$SCRIPT" |sed 's,.*=,, ; s,"\(.*\)",\1,g ; s,^\$[^ ]\+ ,,g ; s,${[^}]*},,g ; s,target-,,g ; s,\s\+,\n,g'|filter_test -d|sort -f -u )

  for DIR in $CONFIGDIRS; do
    test -e "$DIR/configure" && get_configure_scripts "$DIR/configure"
  done
}

################################################################################
auto_configure() {

(while :; do
    case "$1" in
      *) break ;;
    esac
  done

  get_configure_scripts
  for CFG_SCRIPT in  $CONFIGURE_SCRIPTS; do
    (set -x; "$SHELL" "$CFG_SCRIPT" --help)
  done |grep '^\s*([[:upper:]_]\+|--)' -E >configure-help.txt

  while IFS=" "; read OPT DESC; do
  IFS="
"
    OPTSW=${OPT%%[!-[:alnum:]_]*}
     case "$OPTSW" in
       --with-* ) OPTDEF="without" OPTNAME=${OPTSW#--with*-} ;;
     --without-*) OPTDEF="with" OPTNAME=${OPTSW#--with*-} ;;
       --disable-*) OPTDEF="enable" OPTNAME=${OPTSW#--*able-} ;;
       --enable-*) OPTDEF="disable" OPTNAME=${OPTSW#--*able-} ;;
       --*dir | --*prefix) OPTNAME=${OPTSW#--} ;;
       [[:upper:]_]*) ;;
       *) continue ;;
     esac
     OS=$(retok - _ "$OPTSW")
     ON=$(retok - _ "$OPTNAME")
     #echo "OS='$OS' ON='$ON' OPT='$OPT' OPTNAME='$OPTNAME'  DESC='$DESC'" 1>&2

     if pushv_unique ALLOPTS "$ON"; then
       setv \
         "${ON}_DEFAULT" "$OPTDEF" \
         "${ON}_NAME" "$ON" \
         "${ON}_SW" "$OPTSW"
     fi

   done <configure-help.txt

   echo "$ALLOPTS"
   IFS="
"
   for OPT in $ALLOPTS; do
    getv "$OPT" DEFAULT  NAME

    var_s=" " var_dump DEFAULT NAME
   done
   )
}

var_dump ()  {
    ( for N in "$@";
    do
        N=${N%%=*};
        O=${O:+$O${var_s-${IFS%${IFS#?}}}}$N=`eval echo '${'$N'}'`;
    done;
    echo "$O" )
}
auto_configure "$@"
