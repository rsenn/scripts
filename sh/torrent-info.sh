#!/bin/bash

IFS="
"
NL="
"
help() {
  cat <<__EOF
Usage: `basename $0 .sh` [options] <files...>

  -H, --file-name    Show filename
  -h, --human-size   Show human-readable size
  -s, --show-size    Show torrent size
  -r, --rename       Rename torrent files
  -n, --derive-name  Derive name
  -p, --print-only   Print commands only
  -f, --force        Force
      --help         Show this help
__EOF


  exit 1 
}

while :; do
  case "$1" in
     --help) HELP=true ; shift ;;
     --debug|-x) DEBUG=true ; shift ;;
    -H | --file*name* ) SHOW_FILENAME=true ; shift ;;
    -h | --human-size | --*human*) HUMAN_SIZE=true SHOW_SIZE=true; shift ;;
    -s | --show-size | --*size*) SHOW_SIZE=true; shift ;;
    -r | --rename | --*rename*) DO_RENAME=true; shift ;;
    -n | --derive-name | --*name*) DERIVE_NAME=true; shift ;;
    -p | --print-only | --*print*) PRINT_ONLY=true; shift ;;
    -f | --force) FORCE=true; shift ;;
    *) break ;;
  esac
done
if [ -z "$*" -o "$HELP" = true ]; then
  help
  exit $?
fi

ctor_listfiles()
{
 (DIR= FILE= O=
 IFS="
"
  set -- $CTOR
  while [ "$1" != "FILES INFO" ]; do
    shift
    [ $# -eq 0 ] && exit 2
  done
  shift
  while [ $# -gt 0 ]; do
    LINE="$1"
    shift
    case "$LINE" in
      "Directory: "*)
        DIR=${LINE#"Directory: "}
      ;;
      "<"*">"*" ["*"]"*)
        N=${LINE#"<"}; N=${N%">"*}
        LINE=${LINE#*">"}
        while [ "${LINE:0:1}" = " " ]; do LINE=${LINE#" "}; done
        FILE=${LINE%" ["*"]"*}
        LINE=${LINE##*" ["}
        SIZE=${LINE%"]"*}

      #eval "O=\"\${O:+\$O
#}${OUTPUT:-\${DIR:+\$DIR/}\${FILE}}\""
      ECMD="echo \"${OUTPUT}\"" #-\${DIR:+\$DIR/}\${FILE}}\""
      [ "$DEBUG" = true ] && echo "ECMD=\"$ECMD\"" 1>&2
      eval "$ECMD"
      ;;
    *) 
      echo "No such line: $LINE" 1>&2 
      exit 2
      ;;
    esac
  done
  [ "$O" ] && echo "$O") || return $?
}

human_size()
{
  NUM="$1" 
  set -- "" k M G T
  while [ $# -gt 1 -a ${#NUM} -gt 3 ]; do
    NUM=$((NUM / 1024))
    shift
  done
  echo "${NUM}$1"
}

escape() 
{ 
  local s="$1";
  s=${s//"\\"/"\\\\"};
  s=${s//'"'/'\"'};
  echo "$s"
}
ARGS="$*"
ARGC="$#"
OUTPUT='${DIR:+$DIR/}${FILE}'
CMD='ctor_listfiles'


if [ "$SHOW_SIZE" = true ];then 
  [ "$HUMAN_SIZE" = true ] &&
  OUTPUT="$OUTPUT [\$(human_size \$SIZE)]" ||
  OUTPUT="$OUTPUT: \$SIZE"
fi

if [ "$DERIVE_NAME" = true -o "$DO_RENAME" = true ]; then
  CMD="$CMD | ${SED-sed} s,/.*,, | uniq"
 if [ "$DO_RENAME" = true ] ; then
   CMD=" mv -vf -- \"\$ARG\" \"\$($CMD).torrent\" # \$($CMD)"
    [ "$PRINT_ONLY" = true ] && CMD="echo \"$(escape "$CMD")\""
  fi
fi

[ "$ARGC" -gt 1 -o "$SHOW_FILENAME" = true ] && OUTPUT="\$ARG: $OUTPUT"
echo "CMD='$CMD'" 1>&2
for ARG in $ARGS; do
  CTOR=$(ctorrent -x "$ARG")
  if ! [ "$CTOR" ] || ! eval "$CMD"; then
    if [ "$FORCE" != true ]; then
      echo "Failed reading torrent '$ARG'" 1>&2
      exit $?
    fi
  fi
done
