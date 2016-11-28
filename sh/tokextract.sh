#!/bin/bash
# 
tokextract() {
  NL="
  "
  IFS="${NL} "
  tokcharset=$extrachars"_A-Za-z0-9"
  tokexpr="[${tokcharset}]"

  pushv()
  {
	eval "shift;$1=\"\${$1:+\"\$$1\${S:-\$NL}\"}\$*\""
  }

  FILTER="\\|^\$|d"

  while :; do
	 case "$1" in
	   -N | --no*number*) NO_NUMBER=true; shift ;;
	   -e | --expr*) tokexpr="$2"; shift 2 ;;
	   -e=* | --expr*=*) tokexpr="${1#*=}"; shift ;;
	   -e*) tokexpr="${1#-?}"; shift ;;
	   -i | --inc*) pushv INC "$2"; shift 2 ;;
	   -i=* | --inc*=*) pushv INC "${1#*=}"; shift ;;
	   -i*) pushv INC "${1#-?}"; shift ;;
	   -x | --exc*) pushv EXC "$2"; shift 2 ;;
	   -x=* | --exc*=*) pushv EXC "${1#*=}"; shift ;;
	   -x*) pushv EXC "${1#-?}"; shift ;;
	   -u | --uniq*) UNIQ=true; shift ;;
	   -U | --u*case*) pushv FILTER '/[[:lower:]]/d'; shift ;;
	   -L | --l*case*) pushv FILTER '/[[:upper:]]/d'; shift ;;
	   *) break ;;
	 esac
  done

  fnmatch2regexp()
  {
	ARG="$*"
	ARG=${ARG//"*"/"${tokexpr}*"}
	ARG=${ARG//"?"/"${tokexpr}"}
	ARG=${ARG//"."/"\\."}
	
	echo "$ARG"
  }

  SED_ARGS=""

  if [ "$NO_NUMBER" != true ]; then
	pushv FILTER "/^[0-9]/d"
  fi

  set -f

  if [ "$EXC" ]; then
	for X in $EXC; do
	  NOT=
	  case "$X" in
		'!'*) X=${X#'!'}; NOT='!' ;;
	  esac
	  pushv FILTER "\\|^$(fnmatch2regexp "$X")\$|${NOT}d"
	done
  fi

  if [ "$INC" ]; then
	for I in $INC; do
	  NOT=
	  case "$I" in
		'!'*) I=${I#'!'}; NOT='!' ;;
	  esac
	  pushv FILTER "\\|^$(fnmatch2regexp "$I")\$|${NOT}p"
	done
	SED_ARGS="-n"
  fi

  CMD="${SED-sed} \"s|[^\${tokcharset}]|\\\\n|g\" \"\$@\" | ${SED-sed} \$SED_ARGS \"\$FILTER\""

  [ "$UNIQ" = true ] && S=" | " pushv CMD "uniq"

  eval "$CMD"
}

case ${0##*/} in
  -*) ;;
  *tokextract*) tokextract "$@" ;;
esac